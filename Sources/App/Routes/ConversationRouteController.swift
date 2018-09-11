//
//  ConversationRouteController.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import Vapor
import Fluent

struct ConversationRouteController: RouteCollection {
    
    private let conversationController = ConversationController()
    
    func boot(router: Router) throws {
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        
        let conversationGroup = router.grouped("conversations").grouped(tokenAuthMiddleware, guardAuthMiddleware)
        conversationGroup.get(use: fetchAllConversationsHandler)
        conversationGroup.post(NewConversation.self, use: createConversationHandler)
        conversationGroup.get(Conversation.parameter, "messages", use: fetchMessagesInConversationHandler)
    }
}

// MARK: Helper
private extension ConversationRouteController {
    
    func fetchAllConversationsHandler(_ request: Request) throws -> Future<[Conversation]> {
        return try conversationController.fetchAllConversations(for: try request.requireAuthenticated(), on: request)
    }
    
    func fetchMessagesInConversationHandler(_ request: Request) throws -> Future<[Message]> {
        return try request.parameters.next(Conversation.self).flatMap {
            return try self.conversationController.fetchAllMessages(for: $0, on: request)
        }
    }
    
    func createConversationHandler(_ request: Request, newConversation: NewConversation) throws -> Future<Conversation> {
        let user: User = try request.requireAuthenticated()
        let participants = Set([try user.requireID()] + newConversation.recipients)
        return try conversationController.conversation(with: Array(participants), on: request)
    }
}
