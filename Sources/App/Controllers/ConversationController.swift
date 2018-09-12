//
//  ConversationController.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import Vapor
import Fluent

struct ConversationController {
    
    func fetchAllConversations(for user: User, on worker: DatabaseConnectable) throws -> Future<[Conversation]> {
        return try user.conversations.query(on: worker).all()
    }
    
    func fetchAllMessages(for conversation: Conversation, on worker: DatabaseConnectable) throws -> Future<[Message]> {
        return try conversation.messages.query(on: worker).sort(\.createdAt, .ascending).all()
    }
    
    func fetchAllParticipants(for conversation: Conversation, on worker: DatabaseConnectable) throws -> Future<[User.Public]> {
        return try conversation.participants.query(on: worker).all().publicRepresentation()
    }
    
    func conversation(with participants: [User.ID], on worker: DatabaseConnectable) throws -> Future<Conversation> {
        guard participants.count > 1 else { throw Abort(.badRequest) }
        return try existingConversation(with: participants, on: worker).flatMap { conversation in
            return try conversation.map(worker.future) ?? self.newConversation(with: participants, on: worker)
        }
    }
}

// MARK: Helper
private extension ConversationController {
    
    func newConversation(with participants: [User.ID], on worker: DatabaseConnectable) throws -> Future<Conversation> {
        return Conversation().save(on: worker).flatMap { conversation in
            return User.findAll(participants, on: worker).flatMap { users in
                return users.map { $0.conversations.attach(conversation, on: worker) }.flatten(on: worker)
            }.map { recipientPivots in
                return conversation
            }
        }
    }
    
    func existingConversation(with participants: [User.ID], on worker: DatabaseConnectable) throws -> Future<Conversation?> {
        //TODO: Ideally, we can add .groupBy to the query to not have to download EVERY pivot matching one our userIDs (this will be bad with a large participants array)
        //TODO: We should also be able to filter this list on the conversationIDs for THIS USER. This will also help limit the number of pivot matches.
        return ConversationParticipantPivot.query(on: worker).group(.or) { builder in participants.forEach { builder.filter(\.userID == $0) } }.all().flatMap { pivots in
            let groupedPivots = Dictionary(grouping: pivots) { $0.conversationID }
            return groupedPivots.first{ $0.value.count == participants.count }.map { Conversation.find($0.key, on: worker) } ?? worker.future(nil)
        }
    }
}
