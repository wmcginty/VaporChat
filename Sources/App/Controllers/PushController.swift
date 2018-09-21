//
//  PushController.swift
//  App
//
//  Created by William McGinty on 9/14/18.
//

import Foundation
import Vapor
import UrbanVapor

struct PushController {
    
    func sendNewMessagePush(for message: Message, to recipients: [User.ID], in conversation: Conversation, with worker: Request) throws -> Future<HTTPStatus> {
        let urbanService = try worker.make(UrbanVaporService.self)

        return User.findAll(recipients + [message.senderID], on: worker).flatMap { users in
            guard let sender = users.first(where: { $0.id == message.senderID }) else { throw Abort(.internalServerError) }
            let recipientUsers = users.filter { $0.id != message.senderID }
            return try recipientUsers.map {
                let push = self.newMessagePayload(for: message, from: sender, to: $0, in: conversation)
                return try urbanService.send(push, on: worker).transform(to: Void())
            }.flatten(on: worker).transform(to: .created)
        }
    }
    
    func sendTestPush(to recipient: User, with worker: Request) throws -> Future<HTTPStatus> {
        let urbanService = try worker.make(UrbanVaporService.self)
        return try urbanService.send(testPushNotification(to: recipient), on: worker)
    }
}

// MARK: Helper
private extension PushController {
    
    func newMessagePayload(for message: Message, from sender: User, to recipient: User, in conversation: Conversation) -> Push {
        let alert = APNS.Alert(title: sender.email, body: message.contents)
        let notification = UrbanVapor.Notification(apns: APNS(alert: alert, threadID: conversation.id?.uuidString,
                                                              badge: .incrementBy(1), extra: [:], mutableContent: false))
        let push = Push(audience: Audience(namedUser: recipient.email), notification: notification, deviceTypes: DeviceTypes(deviceTypes: .ios))
        return push
    }
    
    func testPushNotification(to recipient: User) -> Push {
        let alert = APNS.Alert(title: "Test Message", body: "Test Body")
        let notification = UrbanVapor.Notification(apns: APNS(alert: alert, threadID: "test-thread-id",
                                                              badge: .incrementBy(1), extra: [:], mutableContent: false))
        let push = Push(audience: Audience(namedUser: recipient.email), notification: notification, deviceTypes: DeviceTypes(deviceTypes: .ios))
        return push
    }
    
}
