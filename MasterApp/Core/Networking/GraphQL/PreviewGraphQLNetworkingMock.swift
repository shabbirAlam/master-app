//
//  PreviewGraphQLNetworkingMock.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 19/04/26.
//

import Foundation

final class PreviewGraphQLNetworkingMock: GraphQLNetworking, Sendable {
    private var mockData: Data?
    private var mockError: Error?
    
    func fetch<T: Decodable>(query: String, variables: [String: AnyEncodable]? = nil) async throws -> T {
        if let mockError {
            throw mockError
        }
        
        if let mockData {
            let data = try JSONDecoder().decode(T.self, from: mockData)
            return data
        }
        throw URLError(.unknown)
    }
    
    func setData<T: Encodable>(_ data: T) {
        mockData = try? JSONEncoder().encode(data)
    }
    
    func setError(_ error: Error) {
        mockError = error
    }
}

#if DEBUG
//final class PreviewGraphQLNetworkingMock: GraphQLNetworkService {
//    private var mockResponses: [String: Data] = [:]
//    private var mockError: Error?
//
//    func fetch<T: Decodable>(_ endpoint: EndpointProtocol) async throws -> T {
//
//        if let mockError {
//            throw mockError
//        }
//
//        let key = endpoint.path
//
//        guard let data = mockResponses[key] else {
//            throw URLError(.badServerResponse)
//        }
//
//        let response = try JSONDecoder().decode(T.self, from: data)
//        print(response)
//        return response
//    }
//
//    func setMock<T: Encodable>(path: String, data: T) {
//        mockResponses[path] = try? JSONEncoder().encode(data)
//    }
//}
#endif // DEBUG
