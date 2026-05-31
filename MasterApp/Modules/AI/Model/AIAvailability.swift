//
//  AIAvailability.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 29/04/26.
//

import FoundationModels

struct AIAvailability {
    static func isEnabled() -> Bool {
        guard #available(iOS 26.0, *) else {
            return false
        }
        
        let model = SystemLanguageModel.default
        
        switch model.availability {
        case .available:
            return true
        default:
            return false
        }
    }
}
