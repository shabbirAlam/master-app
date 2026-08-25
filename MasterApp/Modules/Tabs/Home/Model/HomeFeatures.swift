//
//  HomeFeatures.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Foundation

/// Describes the features available from the app's home screen.
///
/// Each case represents a distinct feature the user can launch, with the
/// `name`, `iconName`, and `description` metadata used to display it in the UI.
enum HomeFeatures: CaseIterable {
    case secureView
    case restAPISearch
    case graphQLSearch
    case chess
//    case aiChat

    /// The display name shown in the feature list.
    var name: String {
        switch self {
        case .secureView: "Secure View"
        case .restAPISearch: "Rest API Search"
        case .graphQLSearch: "GraphQL Search"
        case .chess: "Chess"
//        case .aiChat: "AI Chat"
        }
    }

    /// The SF Symbol name for the feature's icon.
    var iconName: String {
        switch self {
        case .secureView: "lock.shield"
        case .restAPISearch: "magnifyingglass.circle"
        case .graphQLSearch: "network"
        case .chess: "gamecontroller"
//        case .aiChat: "bubble.left.and.bubble.right.fill"
        }
    }

    /// A short description of the feature shown beneath its name.
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
