import Foundation
import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let apiGroup = router.grouped("api")
    
    let routeControllers: [RouteCollection] = [AuthenticationRouteController(), UserRouteController(), ConversationRouteController(), MessageRouteController()]
    try routeControllers.forEach { try $0.boot(router: apiGroup) }
}
