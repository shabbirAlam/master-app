//
//  HomeFeatures.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Foundation

enum HomeFeatures: CaseIterable {
    case secureView
    case restAPISearch
    case graphQLSearch
    
    var name: String {
        return switch self {
        case .secureView: "Secure View"
        case .restAPISearch: "Rest API Search"
        case .graphQLSearch: "GraphQL Search"
        }
    }
}
