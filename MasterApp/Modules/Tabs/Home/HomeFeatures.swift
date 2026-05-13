//
//  HomeFeatures.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Foundation

enum HomeFeatures {
    case ai
    case restAPISearch
    case graphQLSearch
    
    var name: String {
        return switch self {
        case .ai: "AI"
        case .restAPISearch: "Rest API Search"
        case .graphQLSearch: "GraphQL Search"
        }
    }
}
