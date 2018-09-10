//
//  Message.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct NewMessage: Content {
    let contents: String
    let conversationID: Conversation.ID
}

struct Message: Content, SQLiteUUIDModel {
    
    // MARK: Properties
    var id: UUID?
    let contents: String
    let senderID: User.ID
    let conversationID: Conversation.ID

    // MARK: Sender
    var sender: Parent<Message, User> {
        return parent(\.senderID)
    }
    
    // MARK: Conversation
    var conversation: Parent<Message, Conversation> {
        return parent(\.conversationID)
    }
    
    // MARK: Timestampable
    private(set) var createdAt: Date?
    static var createdAtKey: TimestampKey { return \.createdAt }
    
    // MARK: Initializers
    init(sender: User.ID, conversationID: Conversation.ID, contents: String) {
        self.senderID = sender
        self.conversationID = conversationID
        self.contents = contents
    }
}

// MARK: Migration
extension Message: Migration {
    
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.senderID, to: User.idKey)
            builder.reference(from: \.conversationID, to: Conversation.idKey)
        }
    }
}
