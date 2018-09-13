//
//  AuthenticationContainer.swift
//  App
//
//  Created by William McGinty on 3/22/18.
//

import Foundation
import Vapor

struct AuthenticationContainer: Content {
    
    //MARK: Properties
    let userID: User.ID
    let accessToken: AccessToken.Token
    let expiresIn: TimeInterval
    let refreshToken: RefreshToken.Token
    
    //MARK: Initializers
    init(userID: User.ID, accessToken: AccessToken, refreshToken: RefreshToken) {
        self.userID = userID
        self.accessToken = accessToken.tokenString
        self.expiresIn = AccessToken.accessTokenExpirationInterval //Not honored, just an estimate
        self.refreshToken = refreshToken.tokenString
    }
    
    //MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}

struct RefreshTokenContainer: Content {
    
    //MARK: Properties
    let refreshToken: RefreshToken.Token
    
    private enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
