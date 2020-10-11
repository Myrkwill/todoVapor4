import Fluent
import Vapor

struct Migration_v0: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let list = List(name: "Default")
        return database.eventLoop.flatten([
                database.schema(List.schema)
                    .id()
                    .field(.name, .string, .required)
                    .create(),
                database.schema(Todo.schema)
                    .id()
                    .field(.title, .string, .required)
                    .field(.listId, .uuid, .required)
                    .foreignKey(.listId, references: List.schema, .id, onDelete: .cascade, onUpdate: .noAction)
                    .create(),
                database.schema(Detail.schema)
                    .id()
                    .field(. todoId, .uuid, .required)
                    .foreignKey(.todoId, references: Todo.schema, .id, onDelete: .cascade, onUpdate: .noAction)
                    .field(.descriptions, .string, .required)
                    .unique(on: .todoId) //enforce a one-to-one relation
                    .create(),
                database.schema(Tag.schema)
                    .id()
                    .field(.name, .string, .required)
                    .create(),
                database.schema(TodoTags.schema)
                    .id()
                    .foreignKey(.todoId, references: Todo.schema, .id, onDelete: .cascade, onUpdate: .noAction)
                    .foreignKey(.tagId, references: Tag.schema, .id, onDelete: .cascade, onUpdate: .noAction)
                    .field(.todoId, .uuid, .required)
                    .field(.tagId, .uuid, .required)
                    .create(),
                [Tag(name: "work"), Tag(name: "family"), Tag(name: "home")].create(on: database),
                list.create(on: database),
                Todo(title: "Todo 1", listID: list.id!).create(on: database),
            ])
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.eventLoop.flatten([
                database.schema(Detail.schema).delete(),
                database.schema(Todo.schema).delete(),
                database.schema(List.schema).delete(),
                database.schema(Tag.schema).delete(),
                database.schema(TodoTags.schema).delete(),
            ])
        }
}
