import Fluent
import Vapor

struct MessageDTO: Content {
    var id: UUID?
    var chatId: UUID
    var content: String
    var senderRole: String
    var timestamp: Date?

    func toModel() -> Message {
        let model = Message()
        model.id = self.id
        model.chatId = self.chatId
        model.content = self.content
        model.senderRole = self.senderRole
        model.timestamp = self.timestamp
        return model
    }
}
