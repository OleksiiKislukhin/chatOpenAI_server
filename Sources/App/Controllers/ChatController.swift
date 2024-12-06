import Fluent
import Vapor
import Foundation
import OpenAI

struct ChatController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let chats = routes.grouped("chats")

    chats.get(use: getAllChats)
    chats.post(use: createChat)
    chats.group(":chatID") { chat in
      chat.delete(use: deleteChat)
    }
  }

  func getAllChats(req: Request) async throws -> [Chat] {
    do {
      let allChats = try await Chat.query(on: req.db).all()
      
      guard !allChats.isEmpty else {
          throw Abort(.notFound, reason: "Chats not found")
      }
      
      return allChats
    } catch {
      throw Abort(.internalServerError, reason: "Failed to fetch chats: \(error.localizedDescription)")
    }
  }

  func createChat(req: Request) async throws -> Chat {
    let chat: Chat = try req.content.decode(Chat.self)
    try await chat.save(on: req.db)
    return chat
  }

  func deleteChat(req: Request) async throws -> Chat {
    guard let _ = req.parameters.get("chatID"),
      let chat: Chat = try await Chat.find(req.parameters.get("chatID"), on: req.db) else {
      throw Abort(.notFound, reason: "Chat not found")
    }

    try await chat.delete(on: req.db)
    return chat
  }
}
