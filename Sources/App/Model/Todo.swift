import Fluent
import Vapor
import FluentPostgresDriver

extension FieldKey {
    static var title: Self { "title" }
    static var listId: Self { "list_id" }
}

final class Todo: Model, Content {
    static let schema = "todos"
    
    @ID(key: .id) var id: UUID?
    @Field(key: .title) var title: String
    
    @Parent(key: .listId) var list: List
    @Children(for: \.$todo) var details: [Detail]
    
    @Siblings(through: TodoTags.self, from: \.$todo, to: \.$tag) var tags: [Tag]

    init() { }

    init(id: UUID? = nil, title: String, listID: UUID) {
        self.id = id
        self.title = title
        self.$list.id = listID
    }
}


