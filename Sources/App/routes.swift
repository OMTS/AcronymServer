import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world Staging!"
    }

  /*  router.get("acronyms") { req -> Future<[Acronym]> in
        let result = req.withConnection(to: SQLiteDatabase) { db in
            // use the db here
        }
    }*/

    router.post("api", "acronyms") { req -> Future<Acronym> in
        let decededAcronym = try req.content.decode(Acronym.self)
        return decededAcronym.flatMap { acronym  in
            //The next line (mutating the acronym)
            //won't be allowed if we used a struct for Acronym
            //Instead we would have to make a fresh copy of the acronym
            //in order to mutate it

            //acronym.short = "OMG"
            return acronym.save(on: req)
        }
    }
}
