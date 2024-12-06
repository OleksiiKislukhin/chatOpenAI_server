import Fluent

struct CreateMessage: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("messages")
      .id()
      .field("chatID", .uuid, .required)
      .field("content", .string, .required)
      .field("senderRole", .string, .required)
      .field("timestamp", .datetime, .required, .sql(.default("now()")))
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("messages").delete()
  }
}
