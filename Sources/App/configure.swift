import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

public func configure(_ app: Application) async throws {
  app.middleware.use(CORSMiddleware(configuration: .init(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
    allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
  )))

  let hostname = Environment.get("DATABASE_HOST") ?? "localhost"
  let port = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432
  let username = Environment.get("DATABASE_USERNAME") ?? "postgres"
  let password = Environment.get("DATABASE_PASSWORD") ?? "test"
  let database = Environment.get("DATABASE_NAME") ?? "chat_db"

  app.databases.use(DatabaseConfigurationFactory.postgres(
      configuration: .init(
          hostname: hostname,  
          port: port, 
          username: username, 
          password: password,   
          database: database, 
          tls: .disable
      )
  ), as: .psql)

    app.migrations.add(CreateChat())
    app.migrations.add(CreateMessage())

    app.views.use(.leaf)
    app.logger.logLevel = .debug

    try routes(app)
}
