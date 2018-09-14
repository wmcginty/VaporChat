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
    
    func sendNewMessagePush(for message: Message, to recipients: [User.ID], with worker: Request) throws -> Future<HTTPStatus> {
        let urbanService = try worker.make(UrbanVaporService.self)
        let client = try worker.client()
        
        return User.findAll(recipients, on: worker).flatMap { users in
            return try users.map {
                let notification = UrbanVapor.Notification(alert: "New Message", title: message.contents)
                let push = Push(audience: Audience(namedUser: $0.email), notification: notification, deviceTypes: .all)
                return try urbanService.send(push, on: client).transform(to: Void())
            }.flatten(on: worker).transform(to: .created)
        }
    }
}
