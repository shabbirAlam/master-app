//
//  Networking.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Foundation

// MARK: - Networking

protocol Networking: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class NetworkingImpl: Networking, Sendable {
    
    private let session: URLSession
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(configuration: URLSessionConfiguration = .default,
         delegate: URLSessionDelegate? = nil) {
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        self.session = URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }
    
    func request<T : Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.request()
#if DEBUG
        print("Request:", request)
        print("Method:", request.httpMethod ?? "")
        if let httpBody = request.httpBody,
           let json = String(data: httpBody, encoding: .utf8) {
            print("HttpBody:", json)
        }
#endif
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
        
#if DEBUG
        if let json = String(data: data, encoding: .utf8) {
            print("Response:", json)
        }
#endif
        
        do {
            return try Self.decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
#if DEBUG
            print(error)
#endif
            throw NetworkError.decodingError
        }
    }
}
