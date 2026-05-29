//
//  APIEndpoint.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 13/05/26.
//

import Foundation

// MARK: - API Endpoint

struct APIEndpoint: Endpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let queryItems: [URLQueryItem]?
    let body: Encodable?
    var timeout: TimeInterval

    init(baseURL: String = ApiConfig.baseURL,
         path: String,
         method: HTTPMethod = .GET,
         headers: [String: String]? = nil,
         queryItems: [URLQueryItem]? = nil,
         body: Data? = nil,
         timeout: TimeInterval = 30) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
        self.timeout = timeout
    }
}

// MARK: - Endpoint

protocol Endpoint: Sendable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
    var timeout: TimeInterval { get }
}

extension Endpoint {
    func request(with encoder: JSONEncoder) throws -> URLRequest {
        guard let url = URL(string: baseURL),
              var components = URLComponents(url: url.appendingPathComponent(path),
                                             resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        if let body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch let error as EncodingError {
#if DEBUG
                print(error)
#endif
                throw NetworkError.encodingError
            }
        }
        
        headers?.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }
        
        return request
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String, Sendable {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}
