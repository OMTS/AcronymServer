import Vapor
import Fluent
import Crypto

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api", "users")

        userRoutes.get(use: getAllHandler)
        userRoutes.get(User.parameter, use: getHandler)

        userRoutes.post(User.self, use: createHandler)

        userRoutes.get(User.parameter, Constants.Routes.acronyms, use: getAcronymsHandler)
        
    }

    private func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        if let sorted = req.query[String.self, at:"sorted"] {
            if sorted == "true" {
                return User.query(on: req).decode(User.Public.self).sort(\.name, .ascending).all()
            }
        }
        return User.query(on: req).decode(User.Public.self).all()
    }

    private func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }

    private func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }

    private func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in
                return try user.acronyms.query(on: req).all()
        }
    }
}
