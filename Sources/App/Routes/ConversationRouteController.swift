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
        conversationGroup.get(Conversation.parameter, "messages", use: fetchMessagesInConversationHandler)
        conversationGroup.get(Conversation.parameter, "participants", use: fetchParticipantsInConversationHandler)
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
    
    func fetchParticipantsInConversationHandler(_ request: Request) throws -> Future<[User.Public]> {
        return try request.parameters.next(Conversation.self).flatMap {
            return try self.conversationController.fetchAllParticipants(for: $0, on: request)
        }
    }
}
