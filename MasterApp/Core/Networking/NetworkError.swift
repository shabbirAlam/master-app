//
//  NetworkError.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case unknown
    case invalidURL
    case decodingError
    case encodingError
    case invalidResponse
    case badStatusCode(Int)
}
// TODO: - Add one customErrorMessage method which will return either NetworkError or any other msg -
// this will be generic and used in all the apps
extension NetworkError {
    // this will set the localizedDescription variable
    var errorDescription: String? {
        return switch self {
        case .invalidResponse: "Server is not responding properly"
        case .badStatusCode(let code):
            switch code {
            case 401: "Unauthorized access"
            case 500...599: "Server error, please try again later."
            default: "Request failed (\(code))"
            }
        case .unknown,
                .decodingError,
                .encodingError: "Something went wrong, please try again later."
        case .invalidURL: "Invalid URL"
        }
    }
}
