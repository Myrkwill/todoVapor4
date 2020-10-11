import Vapor
import Mailgun
import Leaf

func routes(_ app: Application) throws {
    try app.register(collection: ListController())
    try app.register(collection: TodoController())
    try app.register(collection: TagController())
}
