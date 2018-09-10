//
//  Request+Query.swift
//  App
//
//  Created by William McGinty on 9/10/18.
//

import Foundation
import Vapor
import Fluent

extension QueryContainer {
    
    struct Page {
        let count: Int
        let offset: Int
        
        var range: Range<Int> {
            return offset..<count+offset
        }
    }
    
    func pageInformation() -> Page {
        return Page(count: (try? get(Int.self, at: "count")) ?? .max, offset: (try? get(Int.self, at: "offset")) ?? 0)
    }
}

//MARK: Paging
extension QueryBuilder {
    
    func paged(to page: QueryContainer.Page) -> Self {
        return self.range(page.range)
    }
}
