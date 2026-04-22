//
//  HomeFeatures.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Foundation

enum HomeFeatures {
    case todo
    
    var name: String {
        switch self {
            case .todo:
                return "Todo"
        }
    }
}
