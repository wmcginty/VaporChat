//
//  Conversation.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct NewConversation: Content {
    let recipients: [User.ID]
}

struct Conversation: Content, PostgreSQLUUIDModel, Migration {
    
    // MARK: Properties
    var id: UUID?
    var messages: Children<Conversation, Message> {
        return children(\.conversationID)
    }
    var participants: Siblings<Conversation, User, ConversationParticipantPivot> {
        return siblings()
    }
    
    // MARK: Timestampable
    private(set) var createdAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    
    private(set) var updatedAt: Date?
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
}

// MARK: Parameter
extension Conversation: Parameter { }
