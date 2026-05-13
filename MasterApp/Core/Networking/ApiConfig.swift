//
//  ApiConfig.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 24/04/26.
//

import Foundation

struct ApiConfig {
    static var baseURL: String {
        #if DEBUG
        return "https://dev-api.master.com"
        #else
        return "https://api.master.com"
        #endif
    }
    
    static var graphQLBaseURL: String {
        #if DEBUG
        return "https://countries.trevorblades.com/"
        #else
        return "https://countries.trevorblades.com/"
        #endif
    }
    
    static var todoBaseURL: String {
        #if DEBUG
        return "https://jsonplaceholder.typicode.com/"
        #else
        return "https://jsonplaceholder.typicode.com/"
        #endif
    }
}
