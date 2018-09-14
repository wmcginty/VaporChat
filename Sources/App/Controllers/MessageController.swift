//
//  MessageController.swift
//  App
//
//  Created by William McGinty on 9/14/18.
//

import Foundation
import Vapor
import Fluent
import UrbanVapor

struct MessageController {
    
    private let conversationController = ConversationController()
    
    func postNewMessage(message: NewMessage, from user: User, to conversation: Conversation, with worker: Request) throws -> Future<HTTPStatus> {
        let newMessage = Message(sender: try user.requireID(), conversationID: try conversation.requireID(), contents: message.contents)
        return newMessage.save(on: worker).flatMap { savedMessage in
            let urbanService = try worker.make(UrbanVaporService.self)
            let client = try worker.client()
            let n = UrbanVapor.Notification()
            let push = Push(audience: Audience(namedUser: <#T##String#>), notification: Notification(, deviceTypes: <#T##DeviceTypes#>)
            
            return message.recipients.map { try urbanService.send(push, on: client) }.flatten(on: worker).transform(to: .created)
        }
        
    }
    
    
}


private extension MessageRouteController {
    
    func createNewMessageHandler(_ request: Request, message: NewMessage) throws -> Future<HTTPStatus> {
        let user: User = try request.requireAuthenticated()
        let recipients = Set([try user.requireID()] + message.recipients)
        
        return try conversationController.conversation(with: Array(recipients), on: request).flatMap { conversation in
            let newMessage = Message(sender: try user.requireID(), conversationID: try conversation.requireID(), contents: message.contents)
            return newMessage.save(on: request).transform(to: .created)
        }
    }
}
