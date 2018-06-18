import FluentPostgreSQL
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()

    var databaseConfig: PostgreSQLDatabaseConfig?
    if let databaseURL = Environment.get("DATABASE_URL") {
        databaseConfig = try PostgreSQLDatabaseConfig(url: databaseURL)
    } else {
        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
        let username = Environment.get("DATABASE_USER") ?? "vapor"
        let password = Environment.get("DATABASE_PASSWORD") ?? "password"

        let databaseName: String
        let databasePort: Int
        if (env == .testing) {
            databaseName = "vapor-test"
            if let testPort = Environment.get("DATABASE_PORT") {
                databasePort = Int(testPort) ?? 5437
            } else {
                databasePort = 5437
            }
        }
        else {
            databaseName = Environment.get("DATABASE_DB") ?? "vapor"
            databasePort = 5436
        }
        databaseConfig = PostgreSQLDatabaseConfig(
            hostname: hostname,
            port: databasePort,
            username: username,
            database: databaseName,
            password: password)
    }
    let database = PostgreSQLDatabase(config: databaseConfig!) //crash early if database config is nil
    databases.add(database: database, as: .psql)
    services.register(databases)


    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymCategoryPivot.self, database: .psql)
    services.register(migrations)

    var commandConfig = CommandConfig.default()
    commandConfig.use(RevertCommand.self, as: "revert")
    services.register(commandConfig)

    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}
