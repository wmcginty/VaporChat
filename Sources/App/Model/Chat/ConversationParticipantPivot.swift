//
//  ConversationParticipantPivot.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import FluentPostgreSQL

final class ConversationParticipantPivot: PostgreSQLUUIDPivot, ModifiablePivot {
    
    // MARK: Properties
    var id: UUID?
    var userID: User.ID
    var conversationID: Conversation.ID

    typealias Left = User
    typealias Right = Conversation

    static let leftIDKey: LeftIDKey = \.userID
    static let rightIDKey: RightIDKey = \.conversationID

    // MARK: Initializers
    init(_ user: User, _ conversation: Conversation) throws {
        self.userID = try user.requireID()
        self.conversationID = try conversation.requireID()
    }
}

// MARK: Migration
extension ConversationParticipantPivot: Migration {
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            
            builder.reference(from: \.userID, to: \User.id, onDelete: .cascade)
            builder.reference(from: \.conversationID, to: \Conversation.id, onDelete: .cascade)
        }
    }
}
