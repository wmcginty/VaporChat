//
//  User.swift
//  App
//
//  Created by William McGinty on 3/21/18.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

struct User: Content, PostgreSQLUUIDModel, Migration, Parameter {
    
    //MARK: Properties
    var id: UUID?
    private(set) var email: String
    private(set) var password: String
    
    // MARK: Timestampable
    private(set) var createdAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    
    //MARK: Conversations
    var conversations: Siblings<User, Conversation, ConversationParticipantPivot> {
        return siblings()
    }
    
    // MARK: Initializers
    init(id: UUID? = nil, email: String, password: String) {
        self.id = id
        self.email = email
        self.password = password
    }
}

//MARK: BasicAuthenticatable
extension User: BasicAuthenticatable {
    
    static let usernameKey: WritableKeyPath<User, String> = \.email
    static let passwordKey: WritableKeyPath<User, String> = \.password
}

//MARK: TokenAuthenticatable
extension User: TokenAuthenticatable {
    typealias TokenType = AccessToken
}

//MARK: Validatable
extension User: Validatable {
    
    static func validations() throws -> Validations<User> {
        var validations = Validations(User.self)
        validations.add(\.email, at: [], .email)
        
        return validations
    }
}

// MARK: PublicRepresentable
extension User: PublicRepresentable {
    struct Public: Content {
        let id: UUID
        let email: String
    }
    
    func publicRepresentation() throws -> User.Public {
        return User.Public(id: try requireID(), email: email)
    }
}
