//
//  MessageRouteController.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import Vapor
import Fluent

struct MessageRouteController: RouteCollection {
    
    private let conversationController = ConversationController()
    private let messageController = MessageController()
    
    func boot(router: Router) throws {
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        
        let messageGroup = router.grouped("messages").grouped(tokenAuthMiddleware, guardAuthMiddleware)
        messageGroup.post(NewMessage.self, use: createNewMessageHandler)
    }
}

// MARK: Helper
private extension MessageRouteController {
    
    func createNewMessageHandler(_ request: Request, message: NewMessage) throws -> Future<HTTPStatus> {
        let user: User = try request.requireAuthenticated()
        let recipients = Set([try user.requireID()] + message.recipients)
        
        return try conversationController.conversation(with: Array(recipients), on: request).flatMap { conversation in
            return try self.messageController.postNewMessage(message: message, from: user, to: conversation, with: request)
        }
    }
}

