import Fluent
import Vapor
import Foundation
import OpenAI
import NIO

struct MessageController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let messages = routes.grouped("messages")
    messages.get(use: getMessages)
    messages.post(use: createMessage)

    let ai_chat = routes.grouped("ai_chat")
    ai_chat.get(use: getOpenAIResponse)

    let ai_chat_test = routes.grouped("ai_chat_test")
    ai_chat_test.get(use: questionAI)
  }

  func getMessages(req: Request) async throws -> [Message] {
    guard let chatId: UUID = req.query[UUID.self, at: "chatId"] else {
      throw Abort(.badRequest, reason: "Missing chatId query parameter")
    }

    return try await Message.query(on: req.db)
      .filter(\.$chatId == chatId)
      .all()
  }

  func createMessage(req: Request) async throws -> Message {
    let messageData: MessageDTO = try req.content.decode(MessageDTO.self)

    guard let _ = try await Chat.find(messageData.chatId, on: req.db) else {
        throw Abort(.notFound, reason: "Chat not found")
    }

    let message: Message = Message(
        chatId: messageData.chatId,
        content: messageData.content,
        senderRole: messageData.senderRole
    )

    try await message.save(on: req.db)

    return message
  }

  func questionAI(req: Request) async throws -> String {
    guard let question: String = req.query[String.self, at: "question"] else {
      throw Abort(.badRequest, reason: "Missing question query parameter")
    }

    let chatResponse: String = try await getOpenAIAnswer(content: question)

    return chatResponse
  }

  func getOpenAIAnswer(content: String) async throws -> String {
    guard let openAIKey = Environment.get("OPENAI_API_KEY") else {
      throw Abort(.badRequest, reason: "Missing OpenAI API key. Set OPENAI_API_KEY environment variable.")
    }
    let openAI = OpenAI(apiToken: openAIKey)
    
      
    guard let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: content) else {
      throw Abort(.notFound, reason: "Chat not found")
    }
    
    let query = ChatQuery(messages: [userMessage], model: .gpt4, stream: false)
    let chatsStream = try await openAI.chatsStream(query: query)

    var response = ""
    for try await partialChatResult in chatsStream {
      for choice in partialChatResult.choices {
        if let content = choice.delta.content {
          response += content
        }
      }
    }

    return response
  }

  func getOpenAIResponse(req: Request) async throws -> Response {
    guard let question: String = req.query[String.self, at: "question"] else {
      throw Abort(.badRequest, reason: "Missing question query parameter")
    }

    guard let chatId = req.query[UUID.self, at: "chatId"] else {
      throw Abort(.badRequest, reason: "Missing chatId query parameter")
    }

    guard let _ = try await Chat.find(chatId, on: req.db) else {
        throw Abort(.notFound, reason: "Chat not found")
    }

    let response = Response(status: .ok)
    response.headers.add(name: .contentType, value: "text/event-stream")

    response.body = .init(stream: { writer in
      Task {
        var completeAIResponse = ""

        do {
          guard let openAIKey: String = Environment.get("OPENAI_API_KEY") else {
            throw Abort(.badRequest, reason: "Missing OpenAI API key. Set OPENAI_API_KEY environment variable.")
          }
          let openAI: OpenAI = OpenAI(apiToken: openAIKey)

          guard let message: ChatQuery.ChatCompletionMessageParam = ChatQuery.ChatCompletionMessageParam(role: .user, content: question) else {
            throw Abort(.notAcceptable, reason: "Unacceptable question.")
          }

          let query: ChatQuery = ChatQuery(messages: [message], model: .gpt4, stream: true)

          for try await partialChatResult in openAI.chatsStream(query: query) {
            for choice in partialChatResult.choices {
              if let content = choice.delta.content {
                let message = "data: \(content)\n\n" // SSE message format
                completeAIResponse += content

                try await writer.write(.buffer(ByteBuffer(string: message)))
              }
            }
          }
          
          let aiMessage = Message(chatId: chatId, content: completeAIResponse, senderRole: "ai-chat")
          try await aiMessage.save(on: req.db)

          try await writer.write(.buffer(ByteBuffer(string: "data: [DONE]\n\n")))
          try await writer.write(.end)
        } catch {
          let errorMessage = "data: Error: \(error.localizedDescription)\n\n"
          try await writer.write(.buffer(ByteBuffer(string: errorMessage)))
          try await writer.write(.end)
        }
      }
    })
    
    return response
  }
}