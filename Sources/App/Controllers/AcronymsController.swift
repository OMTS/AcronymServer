import Vapor
import Fluent

struct AcronymsController: RouteCollection {

    func boot(router: Router) throws {
        let acronymsRoutes = router.grouped("api", "acronyms")

        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.post(Acronym.self, use: createHandler)
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        acronymsRoutes.put(Acronym.parameter, use: updateHandler)
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
        acronymsRoutes.get(Constants.Routes.search, use: searchHandler)
        acronymsRoutes.get(Constants.Routes.dsearch, use: multipleSearchHandler)
        acronymsRoutes.get(Constants.Routes.first, use: getFirstHandler)
        acronymsRoutes.get(Constants.Routes.sorted, use: sortedHandler)

        acronymsRoutes.get(Acronym.parameter, Constants.Routes.user, use: getUserHandler)
        acronymsRoutes.post(Acronym.parameter,"categories", Category.parameter, use: addCategoriesHandler)
        acronymsRoutes.get(Acronym.parameter, "categories", use: getCategoriesHandler)

    }

    //CRUD Handlers
    private func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        if let sorted = req.query[String.self, at:"sorted"] {
            if sorted == "true" {
                return try Acronym.query(on: req).sort(\.short, .ascending).all()
            }
        }
        return Acronym.query(on: req).all()
    }

   /* private func createHandler(_ req: Request) throws -> Future<Acronym> {
        let decodedAcronym = try req.content.decode(Acronym.self)
        return decodedAcronym.flatMap { acronym  in
            //The next line (mutating the acronym)
            //won't be allowed if we used a struct for Acronym
            //Instead we would have to make a fresh copy of the acronym
            //in order to mutate it

            //acronym.short = "OMG"
            return acronym.save(on: req)
        }
    }*/

    private func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }

    private func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }

    private func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) { acronym, updatedAcronym in

                            acronym.short = updatedAcronym.short
                            acronym.long = updatedAcronym.long
                            acronym.userID = updatedAcronym.userID
                            return acronym.save(on: req)
        }
    }

    private func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }

    //Filtering Handlers
    private func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at:"term"] else {
            throw Abort(.badRequest)
        }
        let query = Acronym.query(on: req)
        return try query.filter(\.short == searchTerm).all()
    }

    private func multipleSearchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at:"term"] else {
            throw Abort(.badRequest)
        }
        let query = Acronym.query(on: req)
        return try query.group(.or) { or in
            try or.filter(\.short == searchTerm)
            try or.filter(\.long == searchTerm)
            }.all()
    }

    private func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                return acronym
        }
    }

    private func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        let query = Acronym.query(on: req)
        return try query.sort(\.short, .ascending).all()
    }

    //User handler
    private func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self)
            .flatMap { acronym  in
                return try acronym.user.get(on: req)
            }
    }

    //Category handlers
    private func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self)) { acronym, category in
                let pivot = try AcronymCategoryPivot(acronym.requireID(), category.requireID())
                return pivot.save(on: req).transform(to: .created)
        }
    }

    private func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self)
            .flatMap { acronym  in //flatMap(to: [Category].self)
                return try acronym.categories.query(on: req).all()
        }
    }
}
