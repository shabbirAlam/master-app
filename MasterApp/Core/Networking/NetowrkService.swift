//
//  ContentView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Foundation

protocol Networking: Sendable {
    func request<T: Decodable>(_ url: URL) async throws -> T
}

final class NetworkingImpl: Networking, Sendable {
    
    private let session: URLSession
    private static let decoder = JSONDecoder()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ url: URL) async throws -> T {
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
        #if DEBUG
        print(String(data: data, encoding: .utf8)!)
        #endif
        return try Self.decoder.decode(T.self, from: data)
    }
}
