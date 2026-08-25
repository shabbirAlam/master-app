//
//  AppRoute.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Foundation

/// Top-level navigation destinations for the app.
enum AppRoute: Hashable {
    /// Navigates to a route within the Home tab.
    case home(type: HomeRoute)
    /// Navigates to a route within the Profile tab.
    case profile(type: ProfileRoute)
}

/// Navigation destinations available in the Profile tab.
enum ProfileRoute: Hashable {
    /// Opens the profile editing screen.
    case editProfile
}

/// Navigation destinations available in the Home tab.
enum HomeRoute: Hashable {
    /// Opens the secure content demo screen.
    case secureView
    /// Opens the GraphQL country search screen.
    case graphQLSearch
    /// Opens the REST API todo search screen.
    case restAPISearch
    /// Opens the chess puzzle screen.
    case chess
}
