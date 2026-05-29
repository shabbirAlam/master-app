//
//  HomeFeatures.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Foundation
/*
 Need to add:
 1. Combine
 2. Core Data
 
 */
enum HomeFeatures {
    case ai
    case secureView
    case restAPISearch
    case graphQLSearch
    
    var name: String {
        return switch self {
        case .ai: "AI"
        case .secureView: "Secure View"
        case .restAPISearch: "Rest API Search"
        case .graphQLSearch: "GraphQL Search"
        }
    }
}
