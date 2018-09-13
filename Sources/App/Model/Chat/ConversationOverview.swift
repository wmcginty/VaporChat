//
//  ConversationOverview.swift
//  App
//
//  Created by William McGinty on 9/12/18.
//

import Foundation
import Vapor

struct ConversationOverview: Content {
    
    // MARK: Properties
    let id: UUID?
    let participants: [User.Public]
    let updatedAt: Date?
    
    // MARK: Initializers
    init(id: UUID?, participants: [User.Public], updatedAt: Date?) {
        self.id = id
        self.updatedAt = updatedAt
        self.participants = participants
    }
}
