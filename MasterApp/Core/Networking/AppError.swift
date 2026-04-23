//
//  AppError.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Foundation

enum AppError: LocalizedError {
    case network(String)
    case unknown
    
    // this will set the localizedDescription variable
    var errorDescription: String? {
        switch self {
            case .network(let msg):
                return msg
            case .unknown:
                return "Something went wrong"
        }
    }
}

extension AppError {
    static func map(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            switch networkError {
                case .invalidResponse:
                    return .network("Server is not responding properly")
                    
                case .badStatusCode(let code):
                    switch code {
                        case 401:
                            return .network("Unauthorized access")
                        case 500:
                            return .network("Server error, please try later")
                        default:
                            return .network("Request failed (\(code))")
                    }
            }
        }
        
        return .unknown
    }
}
