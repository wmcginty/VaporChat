//
//  UserRouteController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Vapor
import Fluent
import Crypto

class UserRouteController: RouteCollection {
    
    private let authController = AuthenticationController()
    private let userController = UserController()
    private let conversationController = ConversationController()
    
    func boot(router: Router) throws {
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        
        let usersGroup = router.grouped("users").grouped([tokenAuthMiddleware, guardAuthMiddleware])
        usersGroup.get(use: fetchUsersHandler)
        usersGroup.get("testpush", User.parameter, use: testPushHandler)
    }
}

//MARK: Helper
private extension UserRouteController {
    
    func fetchUsersHandler(_ request: Request) throws -> Future<[User.Public]> {
        return try userController.searchForUser(withQuery: request.query, on: request)
    }
    
    func testPushHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(User.self).flatMap { user in
            return try PushController().sendTestPush(to: user, with: request)
        }
    }
}

