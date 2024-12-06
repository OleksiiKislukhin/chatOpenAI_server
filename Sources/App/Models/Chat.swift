import Fluent
import Vapor

final class Chat: Model, Content, @unchecked Sendable {
    static let schema = "chats"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
