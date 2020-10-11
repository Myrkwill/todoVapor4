import Vapor
import Fluent

extension FieldKey {
    static var name: Self { "name" }
}

final class Tag: Model, Content {

    static let schema = "tags"

    @ID() var id: UUID?
    @Field(key: .name) var name: String
    @Siblings(through: TodoTags.self, from: \.$tag, to: \.$todo) var todos: [Todo]
    
    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
