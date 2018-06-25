import Vapor
import Foundation
import FluentPostgreSQL

final class AcronymCategoryPivot: PostgreSQLUUIDPivot {
    var id: UUID?

    var acronymID: Acronym.ID
    var categoryID: Category.ID

    typealias Left = Acronym
    typealias Right = Category

    static var leftIDKey: LeftIDKey = \.acronymID
    static var rightIDKey: RightIDKey = \.categoryID

    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}


extension AcronymCategoryPivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.acronymID, to: \Acronym.id, onUpdate: .cascade)
            builder.reference(from: \.categoryID, to: \Category.id)
        }
    }
}
