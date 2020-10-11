import Vapor
import Fluent

extension FieldKey {
    static var tagId: Self { "tag_id" }
}

final class TodoTags: Model, Content {

    static let schema = "todo_tags"
    
    @ID() var id: UUID?
    @Parent(key: .todoId) var todo: Todo
    @Parent(key: .tagId) var tag: Tag
    
    init() {}
    
    init(todoId: UUID, tagId: UUID) {
        self.$todo.id = todoId
        self.$tag.id = tagId
    }
}
