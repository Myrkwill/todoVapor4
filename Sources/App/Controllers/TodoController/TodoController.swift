import Fluent
import Vapor

struct TodoController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("lists", ":listID", "todos")
        // todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.post("delete", use: delete)
            todo.post("todotags", ":tagID", "delete", use: deleteTodoTag)
            todo.post("todotags", use: addTodoTag)
            todo.group("edit") {
                $0.get(use: edit)
                $0.post(use: update)
            }
            
        }
    }
    
    func index(req: Request) throws -> EventLoopFuture<View> {
        return try todos(req: req).flatMap { req.view.render("todos", Context(todos: $0)) }
    }

    func create(req: Request) throws -> EventLoopFuture<Response> {
        let id = req.parameters.get("listID", as: UUID.self)!
        return try createTodo(listID: id, req: req).map { req.redirect(to: "/lists/\(id)/todos") }
    }

    func delete(req: Request) throws -> EventLoopFuture<Response> {
        let id = req.parameters.get("listID", as: UUID.self)!
        return try deleteTodo(req: req).map{ req.redirect(to: "/lists/\(id)/todos") }
    }
    
    func edit(req: Request) throws -> EventLoopFuture<View> {
        let id = req.parameters.get("todoID", as: UUID.self)!
        let todo = Todo.find(id, on: req.db).unwrap(or: Abort(.notFound))
        let tags = Tag.query(on: req.db).all()
        
        return todo.flatMap { todo in
            return todo.$details.get(on: req.db).flatMap { details in
                return todo.$tags.get(on: req.db).flatMap { todoTags in
                    return tags.flatMap { tags in
                        return req.view.render("todo", EditContext(todo: todo, details: details, tags: tags, todoTags: todoTags))
                    }
                }
            }
        }
    }
    
    func update(req: Request) throws -> EventLoopFuture<Response> {
        let listID = req.parameters.get("listID", as: UUID.self)!
        let todoID = req.parameters.get("todoID", as: UUID.self)!
        return try updateTodo(req: req).map { req.redirect(to: "/lists/\(listID)/todos/\(todoID)/edit") }
    }
    
    func addTodoTag(req: Request) throws -> EventLoopFuture<Response> {
        let createTodoTag = try req.content.decode(CreateTodoTag.self)
        let listID = req.parameters.get("listID", as: UUID.self)!
        let todoID = req.parameters.get("todoID", as: UUID.self)!
        
        let tag = Tag.find(createTodoTag.selected, on: req.db).unwrap(or: Abort.notFound)
        let todo = Todo.find(todoID, on: req.db).unwrap(or: Abort.notFound)
        
        return tag.and(todo)
            .flatMap { tag, todo in
                todo.$tags.isAttached(to: tag, on: req.db).flatMap { isAttach in
                    guard isAttach else { return todo.$tags.attach(tag, on: req.db)}
                }
            }
            .map {
                req.redirect(to: "/lists/\(listID)/todos/\(todoID)/edit")
            }
    }
    
    func deleteTodoTag(request: Request) throws -> EventLoopFuture<Response> {
        let listID = request.parameters.get("listID", as: UUID.self)!
        let todoID = request.parameters.get("todoID", as: UUID.self)!
        let tagID = request.parameters.get("tagID", as: UUID.self)!
        
        let tag = Tag.find(tagID, on: request.db).unwrap(or: Abort.notFound)
        let todo = Todo.find(todoID, on: request.db).unwrap(or: Abort.notFound)
        return tag.and(todo)
            .flatMap { tag, todo in
                todo.$tags.detach(tag, on: request.db)
            }
            .map {
                request.redirect(to: "/lists/\(listID)/todos/\(todoID)/edit")
            }
    }
    
    struct CreateTodoTag: Content {
        let selected: UUID
    }
}

extension TodoController {
    func updateTodo(req: Request) throws -> EventLoopFuture<Void> {
        let contentTodo = try req.content.decode(CreateTodo.self)
    
        return try todo(req: req).flatMap { todo in
                todo.title = contentTodo.title
                return todo.update(on: req.db)
        }
    }
    
    func todos(req: Request) throws -> EventLoopFuture<[Todo]> {
        return Todo.query(on: req.db).all()
    }
    
    func createTodo(listID: UUID, req: Request) throws -> EventLoopFuture<Void> {
        let createTodo = try req.content.decode(CreateTodo.self)
        let todo = Todo(title: createTodo.title, listID: listID)
        return todo.create(on: req.db)
    }
    
    func deleteTodo(req: Request) throws -> EventLoopFuture<Void> {
        return try todo(req: req).flatMap { $0.delete(on: req.db) }
    }
    
    func todo(req: Request) throws -> EventLoopFuture<Todo> {
        let id = req.parameters.get("todoID", as: UUID.self)!
        return Todo.find(id, on: req.db).unwrap(or: Abort(.notFound))
    }
    
}

extension TodoController {
    struct Context: Codable {
        var todos: [Todo]
    }

    struct EditContext: Codable {
        var todo: Todo
        var details: [Detail]
        var tags: [Tag]
        var todoTags: [Tag]
    }
}



