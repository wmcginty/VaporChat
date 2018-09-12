//
//  UserController.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct UserController {
    
    func searchForUser(withQuery queryContainer: QueryContainer, on worker: DatabaseConnectable) throws -> Future<[User.Public]> {
        let userQuery: QueryBuilder<User.Database, User>
        switch try? queryContainer.get(String.self, at: "email") {
        case .some(let query): userQuery = User.query(on: worker).filter(\.email ~~ query)
        case .none: userQuery = User.query(on: worker)
        }
        
        let page = queryContainer.pageInformation()
        return try userQuery.paged(to: page).all().publicRepresentation()
    }
    
}
