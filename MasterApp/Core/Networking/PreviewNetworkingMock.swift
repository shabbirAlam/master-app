//
//  PreviewNetworkingMock.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Foundation

#if DEBUG
final class PreviewNetworkingMock: Networking {
    private var mockData: Data?
    private var mockError: Error?
    
    func request<T>(_ url: URL) async throws -> T where T : Decodable {
        if let mockError {
            throw mockError
        }
        
        if let mockData {
            return try JSONDecoder().decode(T.self, from: mockData)
        }
        
        throw URLError(.badServerResponse)
    }
    
    func setData<T: Encodable>(_ data: T) {
        mockData = try? JSONEncoder().encode(data)
    }
}

//final class PreviewNetworkingMock: Networking {
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
#endif
