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
}
