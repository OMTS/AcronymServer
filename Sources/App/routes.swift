import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello Staging!"
    }

    //CRUD
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        if let sorted = req.query[String.self, at:"sorted"] {
            if sorted == "true" {
                return try Acronym.query(on: req).sort(\.short, .ascending).all()
            }
        }
        return Acronym.query(on: req).all()
    }

    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }

    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) { acronym, updatedAcronym in

            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req)
        }
    }

    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
        .delete(on: req)
        .transform(to: HTTPStatus.noContent)
    }

    router.post("api", "acronyms") { req -> Future<Acronym> in
        let decodedAcronym = try req.content.decode(Acronym.self)
         return decodedAcronym.flatMap { acronym  in
            //The next line (mutating the acronym)
            //won't be allowed if we used a struct for Acronym
            //Instead we would have to make a fresh copy of the acronym
            //in order to mutate it

            //acronym.short = "OMG"
            return acronym.save(on: req)
        }
    }

    //Filtering api
    //Single field search
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at:"term"] else {
            throw Abort(.badRequest)
        }
        let query = Acronym.query(on: req)
        return try query.filter(\.short == searchTerm).all()
    }

    //Multiple fields search
    router.get("api", "acronyms", "multiplesearch") { req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at:"term"] else {
            throw Abort(.badRequest)
        }
        let query = Acronym.query(on: req)
        return try query.group(.or) { or in
            try or.filter(\.short == searchTerm)
            try or.filter(\.long == searchTerm)
        }.all()
    }


    //First result
    router.get("api", "acronyms", "first") {
        req -> Future<Acronym> in
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                return acronym
            }
    }

    //Sorted results
    router.get("api", "acronyms", "sorted") { req -> Future<[Acronym]> in
        let query = Acronym.query(on: req)
        return try query.sort(\.short, .ascending).all()
    }
}
