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
    
    func boot(router: Router) throws {
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        
        let usersGroup = router.grouped("users").grouped([tokenAuthMiddleware, guardAuthMiddleware])
        usersGroup.get(use: fetchUsersHandler)
        
        let conversationGroup = router.grouped("conversations").grouped(tokenAuthMiddleware, guardAuthMiddleware)
        conversationGroup.get(use: fetchAllConversationsHandler)
        conversationGroup.post(NewConversation.self, use: createConversationHandler)
        conversationGroup.get(Conversation.parameter, "messages", use: fetchMessagesInConversationHandler)
        
        let messageGroup = router.grouped("messages").grouped(tokenAuthMiddleware, guardAuthMiddleware)
        messageGroup.post(NewMessage.self, use: createNewMessageHandler)
    }
}

//MARK: Helper
private extension UserRouteController {
    
    func fetchUsersHandler(_ request: Request) throws -> Future<[User.Public]> {
        return try userController.searchForUser(withQuery: request.query, on: request)
    }
    
    func fetchAllConversationsHandler(_ request: Request) throws -> Future<[Conversation]> {
        let user: User = try request.requireAuthenticated()
        return try user.conversations.query(on: request).all()
    }
    
    func fetchMessagesInConversationHandler(_ request: Request) throws -> Future<[Message]> {
        return try request.parameters.next(Conversation.self).flatMap {
            return try $0.messages.query(on: request).sort(Message.createdAtKey).all()
        }
    }
    
    func createConversationHandler(_ request: Request, conversation: NewConversation) throws -> Future<HTTPStatus> {
        let user: User = try request.requireAuthenticated()
        
        return User.find(conversation.recipientID, on: request).flatMap { recipientUser in
            guard let recipientUser = recipientUser else { throw Abort(.badRequest) }
            return Conversation().save(on: request).flatMap { conversation in
                return map(to: HTTPStatus.self, user.conversations.attach(conversation, on: request), recipientUser.conversations.attach(conversation, on: request)) { _, _ in
                    return .created
                }
            }
        }
    }
    
    func createNewMessageHandler(_ request: Request, message: NewMessage) throws -> Future<HTTPStatus> {
        let user: User = try request.requireAuthenticated()
        return Conversation.find(message.conversationID, on: request).flatMap { conversation in
            guard let conversation = conversation else { throw Abort(.notFound) }
            //TODO: Ensure this user is part of the conversation
            
            let newMessage = Message(sender: try user.requireID(), conversationID: try conversation.requireID(), contents: message.contents)
            return newMessage.save(on: request).transform(to: .created)
        }
    }
}

