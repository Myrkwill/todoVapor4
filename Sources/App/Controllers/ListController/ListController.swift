import Fluent
import Vapor

struct ListController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let lists = routes.grouped("lists")
        lists.get(use: index)
        lists.post(use: create)
        
        lists.group(":listID") { list in
            list.post("delete", use: delete)
            list.post("edit", use: update)
            list.get("todos", use: todos)
        }
    }
    
    func index(req: Request) throws -> EventLoopFuture<View> {
        return try lists(req: req).flatMap { req.view.render("lists", Context(lists: $0)) }
    }
    
    func create(req: Request) throws -> EventLoopFuture<Response> {
        return try createList(req: req).map { req.redirect(to: "/lists") }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<Response> {
        return try deleteList(req: req).map{ req.redirect(to: "/lists") }
    }
    
    func todos(req: Request) throws -> EventLoopFuture<View> {
        return try list(req: req).flatMap { list in
            list.$todos.get(on: req.db).flatMap {
                return req.view.render("todos", ListContext(list: list, todos: $0))
            }
        }
    }
    
    func update(req: Request) throws -> EventLoopFuture<Response> {
        let id = req.parameters.get("listID", as: UUID.self)!
        return try updateList(req: req).map{ req.redirect(to: "/lists/\(id)/todos") }
    }
}

extension ListController {
    func deleteList(req: Request) throws -> EventLoopFuture<Void> {
        return try list(req: req).flatMap { $0.delete(on: req.db) }
    }
    
    func updateList(req: Request) throws -> EventLoopFuture<Void> {
        let listRequestBody = try req.content.decode(CreateList.self)
        // guard let name = listRequestBody.name else { throw Abort(.notFound) }
        
        return try list(req: req).flatMap { list in
            list.name = listRequestBody.name
            return list.save(on: req.db)
        }
    }
    
    func list(req: Request) throws -> EventLoopFuture<List> {
        let id = req.parameters.get("listID", as: UUID.self)!
        return List.find(id, on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func lists(req: Request) throws -> EventLoopFuture<[List]> {
        return List.query(on: req.db).all()
    }
    
    func createList(req: Request) throws -> EventLoopFuture<Void> {
        let createList = try req.content.decode(CreateList.self)
        let list = List(name: createList.name)
        return list.save(on: req.db)
    }
}

extension ListController {
    struct Context: Codable {
        var lists: [List]
    }

    struct ListContext: Codable {
        var list: List
        var todos: [Todo]?
    }
    
    struct ListRequestBody: Content {
        let name: String
    }
}

