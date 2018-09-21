//
//  Model+QuerySupporting.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL

extension Model where Database: QuerySupporting {
    static func findAll(_ ids: [Self.ID], on conn: DatabaseConnectable) -> Future<[User]> {
        return User.query(on: conn).filter(idKey ~~ ids).all()
    }
}
