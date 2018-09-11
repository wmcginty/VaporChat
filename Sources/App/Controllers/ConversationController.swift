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
    
    func conversation(for user: User, with participants: [User.ID], on worker: DatabaseConnectable) throws -> Future<Conversation> {
        return try existingConversation(for: user, with: participants, on: worker).flatMap { conversation in
            if let conversation = conversation {
                return worker.future(conversation)
            }
            
            return try self.newConversation(for: user, with: participants, on: worker)
        }
    }

    func existingConversation(for user: User, with participants: [User.ID], on worker: DatabaseConnectable) throws -> Future<Conversation?> {
        //TODO: Ideally, we can add .groupBy to the query to not have to download EVERY pivot matching one our userIDs (this will be bad with a large participants array)
        //TODO: We should also be able to filter this list on the conversationIDs for THIS USER. This will also help limit the number of pivot matches.
        let allParticipants = [try user.requireID()] + participants
        
        return ConversationParticipantPivot.query(on: worker).group(.or) { builder in allParticipants.forEach { builder.filter(\.userID == $0) } }.all().flatMap { pivots in
            let groupedPivots = Dictionary(grouping: pivots) { $0.conversationID }
            return groupedPivots.first{ $0.value.count == allParticipants.count }.map { Conversation.find($0.key, on: worker) } ?? worker.future(nil)
        }
    }
}

// MARK: Helper
private extension ConversationController {
    
    func newConversation(for user: User, with participants: [User.ID], on worker: DatabaseConnectable) throws -> Future<Conversation> {
        return Conversation().save(on: worker).flatMap { conversation in
            let recipientPivots = User.findAll(participants, on: worker).flatMap { users in
                return users.map { $0.conversations.attach(conversation, on: worker) }.flatten(on: worker)
            }
            
            return map(to: Conversation.self, user.conversations.attach(conversation, on: worker), recipientPivots) { userPivot, recipientPivots -> Conversation in
                return conversation
            }
        }
    }
}
