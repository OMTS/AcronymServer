import Vapor
import Fluent

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api", "users")

        userRoutes.get(use: getAllHandler)
        userRoutes.get(User.parameter, use: getHandler)

        userRoutes.post(User.self, use: createHandler)

        userRoutes.get(User.parameter, Constants.Routes.acronyms, use: getAcronymsHandler)
        
    }

    private func getAllHandler(_ req: Request) throws -> Future<[User]> {
        if let sorted = req.query[String.self, at:"sorted"] {
            if sorted == "true" {
                return try User.query(on: req).sort(\.name, .ascending).all()
            }
        }
        return User.query(on: req).all()
    }

    private func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }

    private func createHandler(_ req: Request, user: User) throws -> Future<User> {
        return user.save(on: req)
    }

    private func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in
                return try user.acronyms.query(on: req).all()
        }
    }
}
