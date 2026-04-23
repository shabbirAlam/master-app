//
//  NetworkError.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case badStatusCode(Int)
    case unknown
}

extension NetworkError {
    // this will set the localizedDescription variable
    var errorDescription: String? {
        switch self {
            case .invalidResponse:
                return "Server is not responding properly"
            case .badStatusCode(let code):
                switch code {
                    case 401:
                        return "Unauthorized access"
                    case 500:
                        return "Server error, please try later"
                    default:
                        return "Request failed (\(code))"
                }
            case .unknown:
                return "Something went wrong"
        }
    }
}
