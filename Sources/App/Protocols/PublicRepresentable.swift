//
//  PublicReturnable.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import Vapor

protocol PublicRepresentable {
    associatedtype PublicRepresentationType: Content
    func publicRepresentation() throws -> PublicRepresentationType
}

// MARK: Convenience Extensions
extension Future where T: PublicRepresentable {
    func publicRepresentation() throws -> Future<T.PublicRepresentationType> {
        return map { try $0.publicRepresentation() }
    }
}

extension Array: PublicRepresentable where Element: PublicRepresentable {
    typealias PublicRepresentationType = [Element.PublicRepresentationType]
    
    func publicRepresentation() throws -> [Element.PublicRepresentationType] {
        return try map { try $0.publicRepresentation() }
    }
}
