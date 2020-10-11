import Vapor
import Fluent

final class List: Model, Content {
    static let schema = "lists"

    @ID() var id: UUID?
    @Field(key: .name) var name: String
    @Children(for: \.$list) var todos: [Todo]

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
