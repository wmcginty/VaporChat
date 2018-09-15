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
        //let client = try worker.client()
        
        return User.findAll(recipients, on: worker).flatMap { users in
            return try users.map {
                let notification = UrbanVapor.Notification(alert: message.contents)
                let push = Push(audience: Audience(namedUser: $0.email), notification: notification, deviceTypes: DeviceTypes(deviceTypes: .ios))
                
                return try urbanService.send(push, on: worker).map { response in
                    let logger = try worker.make(Logger.self)
                    logger.info(String(describing: response.http.status))
                    logger.info(String(describing: response.http.body))
                    return
                }
            }.flatten(on: worker).transform(to: .created)
        }
    }
}
