//
//  ApiConfig.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 24/04/26.
//

import Foundation

/// Central configuration of API base URLs, switched by build configuration.
struct ApiConfig {
    /// Base URL for the app's primary REST API (debug vs. release).
    static var baseURL: String {
        #if DEBUG
        return "https://dev-api.master.com"
        #else
        return "https://api.master.com"
        #endif
    }

    /// Base URL for the GraphQL countries API.
    static var graphQLBaseURL: String {
        #if DEBUG
        return "https://countries.trevorblades.com/"
        #else
        return "https://countries.trevorblades.com/"
        #endif
    }

    /// Base URL for the JSONPlaceholder todos API.
    static var todoBaseURL: String {
        #if DEBUG
        return "https://jsonplaceholder.typicode.com/"
        #else
        return "https://jsonplaceholder.typicode.com/"
        #endif
    }
}
