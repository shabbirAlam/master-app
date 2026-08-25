//
//  NetworkError.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Foundation

/// Typed errors surfaced by the networking layer.
enum NetworkError: LocalizedError, Equatable {
    /// An unrecognized failure.
    case unknown
    /// A request URL could not be constructed.
    case invalidURL
    /// Response decoding failed.
    case decodingError
    /// Request body encoding failed.
    case encodingError
    /// The response was not a valid HTTP response.
    case invalidResponse
    /// The server returned an unexpected status code.
    case badStatusCode(Int)
}

extension NetworkError {
    /// User-facing, localized description for each error case.
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
