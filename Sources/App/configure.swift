import Vapor
import Leaf
import Mailgun
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Configure Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    
    // Configure Mailgun
    app.mailgun.configuration = .mailgunKey
    app.mailgun.defaultDomain = .mailgunDomain
    
    // Configure DataBases
    //app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    // Configure PostgreSQL
    try app.databases.use(.postgres(url: .databaseUrl), as: .psql)
    
    // Configure migrations
    app.migrations.add(Migration_v0())
    
    // register routes
    try routes(app)
}

extension URL {
    static let databaseUrl = URL(string: "")!
}

extension MailgunDomain {
    static var mailgunDomain: MailgunDomain { .init("", .us) }
}

extension MailgunConfiguration {
    static var mailgunKey: MailgunConfiguration { .init(apiKey: "") }
}
