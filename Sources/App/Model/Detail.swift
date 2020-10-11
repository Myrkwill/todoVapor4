import Vapor
import Fluent

extension FieldKey {
    static var todoId: Self { "todo_id" }
    static var descriptions: Self { "descriptions" }
}

final class Detail: Model, Content {
    static let schema = "details"

    @ID() var id: UUID?
    @Parent(key: .todoId) var todo: Todo
    @Field(key: .descriptions) var descriptions: [String]

    init() { }

    init(id: UUID? = nil, descriptions: [String], todoId: UUID) {
        self.id = id
        self.descriptions = descriptions
        self.$todo.id = todoId
    }
}
