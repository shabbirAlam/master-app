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
    case chess
//    case aiChat

    var name: String {
        switch self {
        case .secureView: "Secure View"
        case .restAPISearch: "Rest API Search"
        case .graphQLSearch: "GraphQL Search"
        case .chess: "Chess"
//        case .aiChat: "AI Chat"
        }
    }

    var iconName: String {
        switch self {
        case .secureView: "lock.shield"
        case .restAPISearch: "magnifyingglass.circle"
        case .graphQLSearch: "network"
        case .chess: "gamecontroller"
//        case .aiChat: "bubble.left.and.bubble.right.fill"
        }
    }

    var description: String {
        switch self {
        case .secureView: "Protected content with screenshot and video prevention"
        case .restAPISearch: "Search todos via REST API"
        case .graphQLSearch: "Explore countries with GraphQL"
        case .chess: "Play chess with AI opponent"
//        case .aiChat: "Chat with an AI assistant"
        }
    }
}
