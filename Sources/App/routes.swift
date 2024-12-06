import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render( "index", [ "title":  "Server is runing"])
    }

    try app.register(collection: ChatController())
    try app.register(collection: MessageController())
}
