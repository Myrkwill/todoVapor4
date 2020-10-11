import Fluent
import Vapor

struct TagController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let tags = routes.grouped("tags")
        tags.get(use: index)
        tags.post(use: create)
        tags.group(":tagID") { tag in
            tag.post("delete", use: delete)
            tag.get("edit", use: edit)
            tag.post("edit", use: update)
        }
        
        
    }
    
    func index(req: Request) throws -> EventLoopFuture<View> {
        return Tag.query(on: req.db).all().flatMap { req.view.render("tags", Context(tags: $0)) }
    }
    
    struct Context: Content {
        let tags: [Tag]
    }
    
    func create(req: Request) throws -> EventLoopFuture<Response> {
        let createTag = try req.content.decode(CreateTag.self)
        let tag = Tag(name: createTag.name)
        return tag.create(on: req.db).map { req.redirect(to: "/tags") }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<Response> {
        let id = req.parameters.get("tagID", as: UUID.self)!
        
        return Tag
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { req.redirect(to: "/tags") }
    }
    
    func edit(req: Request) throws -> EventLoopFuture<View> {
        return try tag(req: req).flatMap { tag in
            return req.view.render("tag", EditContext(tag: tag))
        }
    }
    
    func update(req: Request) throws -> EventLoopFuture<Response> {
        return try updateTag(req: req).map { req.redirect(to: "/tags") }
    }
    
    struct EditContext: Content {
        let tag: Tag
    }

}

extension TagController {
    func updateTag(req: Request) throws -> EventLoopFuture<Void> {
        let contextEdit = try req.content.decode(CreateTag.self)
    
        return try tag(req: req).flatMap { tag in
                tag.name = contextEdit.name
                return tag.update(on: req.db)
        }
    }
    
    func tag(req: Request) throws -> EventLoopFuture<Tag> {
        let id = req.parameters.get("tagID", as: UUID.self)!
        return Tag.find(id, on: req.db).unwrap(or: Abort(.notFound))
    }
}
