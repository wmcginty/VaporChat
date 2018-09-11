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
        return try conversationController.conversation(for: user, with: message.recipients, on: request).flatMap { conversation in
            
            let newMessage = Message(sender: try user.requireID(), conversationID: try conversation.requireID(), contents: message.contents)
            return newMessage.save(on: request).transform(to: .created)
        }
    }
}

