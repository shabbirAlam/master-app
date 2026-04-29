//
//  HomeFeatures.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Foundation

enum HomeFeatures {
    case todo
    case ai
    
    var name: String {
        return switch self {
        case .todo: "Todo"
        case .ai: "AI"
        }
    }
}
