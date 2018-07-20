import Vapor
import FluentPostgreSQL
import Foundation
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String

    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }

    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
}

extension User {
    var acronyms: Children <User, Acronym> {
        return children(\.userID)
    }
}


extension User: PostgreSQLUUIDModel {}
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.unique(on: \.username)
            }
    }
}
extension User: Content {}
extension User: Parameter {}
extension User.Public: Content {}
extension User.Public: PostgreSQLUUIDModel {}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username)
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "Admin", username: "admin", password: hashedPassword)
        return user.save(on: connection).transform(to: ())
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}
