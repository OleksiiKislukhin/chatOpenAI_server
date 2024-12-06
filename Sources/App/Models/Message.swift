import Fluent
import Vapor

final class Message: Model, Content, @unchecked Sendable {
    static let schema = "messages"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "chatID")
    var chatId: UUID

    @Field(key: "content")
    var content: String

    @Field(key: "senderRole")
    var senderRole: String

    @Timestamp(key: "timestamp", on: .create)
    var timestamp: Date?

    init() {}

    init(id: UUID? = nil, chatId: UUID, content: String, senderRole: String, timestamp: Date? = nil) {
        self.id = id
        self.chatId = chatId
        self.content = content
        self.senderRole = senderRole
        self.timestamp = timestamp ?? Date()
    }

    func toDTO() -> MessageDTO {
        return MessageDTO(
            id: self.id,
            chatId: self.chatId,
            content: self.content,
            senderRole: self.senderRole,
            timestamp: self.timestamp
        )
    }
}
