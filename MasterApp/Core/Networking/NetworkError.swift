//
//  NetworkError.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case unknown
    case decodingError
    case invalidResponse
    case badStatusCode(Int)
}

extension NetworkError {
    // this will set the localizedDescription variable
    var errorDescription: String? {
        return switch self {
        case .invalidResponse:
            "Server is not responding properly"
        case .badStatusCode(let code):
            switch code {
            case 401:
                "Unauthorized access"
            case 500:
                "Server error, please try again later."
            default:
                "Request failed (\(code))"
            }
        case .decodingError: "Something went wrong, please try again later."
        case .unknown: "Something went wrong, please try again later."
        }
    }
}
