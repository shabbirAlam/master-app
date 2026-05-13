//
//  GraphQLNetworking.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 19/04/26.
//

import Foundation

protocol GraphQLNetworking: Sendable {
    func fetch<T: Decodable>(query: String, variables: [String: AnyEncodable]?) async throws -> T
}

final class GraphQLNetworkingImpl: GraphQLNetworking, Sendable {
    
    private let session: URLSession
    private static let decoder = JSONDecoder()
    private let url = URL(string: ApiConfig.graphQLBaseURL)
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(query: String, variables: [String: AnyEncodable]? = nil) async throws -> T {
        guard let url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = GraphQLRequest(query: query, variables: variables)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
        #if DEBUG
        print(String(data: data, encoding: .utf8)!)
        #endif
        return try Self.decoder.decode(GraphQLResponse<T>.self, from: data).data
    }
}
