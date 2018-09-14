import Vapor
import FluentPostgreSQL
import Authentication
import UrbanVapor

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    // Configure Fluents SQL provider
    try services.register(FluentPostgreSQLProvider())
    
    // Configure the authentication provider
    try services.register(AuthenticationProvider())
    
    // Configure our databasep
    if let databaseConfig = try configuredPostgreSQLDatabaseConfig(with: env) {
        var databases = DatabasesConfig()
        let database = PostgreSQLDatabase(config: databaseConfig)
        databases.add(database: database, as: .psql)
        services.register(databases)
    }
    
    //Configure push
    if let key = Environment.get("UA_KEY"), let secret = Environment.get("UA_SECRET") {
        let urbanVaporProvider = UrbanVaporProvider(key: key, secret: secret)
        try services.register(urbanVaporProvider)
    }
    
    // Configure our model migrations
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: User.self, database: .psql)
    migrationConfig.add(model: AccessToken.self, database: .psql)
    migrationConfig.add(model: RefreshToken.self, database: .psql)
    migrationConfig.add(model: Conversation.self, database: .psql)
    migrationConfig.add(model: Message.self, database: .psql)
    migrationConfig.add(model: ConversationParticipantPivot.self, database: .psql)
    services.register(migrationConfig)
}

func configuredPostgreSQLDatabaseConfig(with env: Environment) throws -> PostgreSQLDatabaseConfig? {
    guard let url = Environment.get("DATABASE_URL") else {
        return PostgreSQLDatabaseConfig(hostname: "localhost",
                                        port: 5432,
                                        username: "willmcginty",
                                        database: "chat")
    }
    
    return PostgreSQLDatabaseConfig(url: url)
}
