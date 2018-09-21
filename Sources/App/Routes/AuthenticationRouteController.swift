//
//  AuthenticationController.swift
//  App
//
//  Created by William McGinty on 3/25/18.
//

import Foundation
import Vapor
import Fluent
import Crypto
import Authentication

struct AuthenticationRouteController: RouteCollection {
    
    private let authController = AuthenticationController()
    
    func boot(router: Router) throws {
        router.post(User.self, at: "login", use: loginUserHandler)
        router.post(User.self, at: "register", use: registerUserHandler)
        
        let tokenGroup = router.grouped("token")
        tokenGroup.post(RefreshTokenContainer.self, at: "refresh", use: refreshAccessTokenHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicAuthGroup = router.grouped([basicAuthMiddleware, guardAuthMiddleware])
        basicAuthGroup.post(UserEmailContainer.self, at: "revoke", use: accessTokenRevocationhandler)
    }
}

//MARK: Helper - Tokens
private extension AuthenticationRouteController {
    
    func refreshAccessTokenHandler(_ request: Request, container: RefreshTokenContainer) throws -> Future<AuthenticationContainer> {
        return try authController.authenticationContainer(for: container.refreshToken, on: request)
    }
    
    func accessTokenRevocationhandler(_ request: Request, container: UserEmailContainer) throws -> Future<HTTPStatus> {
        return try authController.revokeTokens(forEmail: container.email, on: request).transform(to: .noContent)
    }
}

//MARK: Helper - Registration
private extension AuthenticationRouteController {
    
    func loginUserHandler(_ request: Request, user: User) throws -> Future<AuthenticationContainer> {
        return User.query(on: request).filter(\.email == user.email).first().flatMap { existingUser in
            guard let existingUser = existingUser else { throw Abort(.badRequest, reason: "this user does not exist" , identifier: nil) }
            
            let digest = try request.make(BCryptDigest.self)
            guard try digest.verify(user.password, created: existingUser.password) else { throw Abort(.badRequest) /* authentication failure */ }
            
            return try self.authController.authenticationContainer(for: existingUser, on: request)
        }
    }
    
    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<AuthenticationContainer> {
        return User.query(on: request).filter(\.email == newUser.email).first().flatMap { existingUser in
            guard existingUser == nil else { throw Abort(.badRequest, reason: "a user with this email already exists" , identifier: nil) }
            
            try newUser.validate()
            return try newUser.user(with: request.make(BCryptDigest.self)).save(on: request).flatMap { user in
                return try self.authController.authenticationContainer(for: user, on: request)
            }
        }
    }
}

private extension User {
    
    func user(with digest: BCryptDigest) throws -> User {
        return try User(id: nil, email: email, password: digest.hash(password))
    }
}
