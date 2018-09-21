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
    
    private let pushController = PushController()
    
    func postNewMessage(message: NewMessage, from user: User, to conversation: Conversation, with worker: Request) throws -> Future<HTTPStatus> {
        let newMessage = Message(sender: try user.requireID(), conversationID: try conversation.requireID(), contents: message.contents)
        return newMessage.save(on: worker).flatMap {
            return try self.pushController.sendNewMessagePush(for: $0, to: message.recipients, in: conversation, with: worker)
        }
    }
}
