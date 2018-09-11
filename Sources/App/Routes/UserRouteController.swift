//
//  UserRouteController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Vapor
import Fluent
import Crypto
import Logging

class UserRouteController: RouteCollection {
    
    private let authController = AuthenticationController()
    private let userController = UserController()
    private let conversationController = ConversationController()
    
    func boot(router: Router) throws {
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        
        let usersGroup = router.grouped("users").grouped([tokenAuthMiddleware, guardAuthMiddleware])
        usersGroup.get(use: fetchUsersHandler)
    }
}

//MARK: Helper
private extension UserRouteController {
    
    func fetchUsersHandler(_ request: Request) throws -> Future<[User.Public]> {
        return try userController.searchForUser(withQuery: request.query, on: request)
    }
}

