//
//  MockNetworkService.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Foundation
@testable import MasterApp

final class MockNetworkServiceImpl: Networking {
    private var mockData: Data?
    private var mockError: Error?
    
    func request<T : Decodable>(_ endpoint: any MasterApp.Endpoint) async throws -> T {
        if let mockError {
            throw mockError
        }
        
        if let mockData {
            let data = try JSONDecoder().decode(T.self, from: mockData)
            return data
        }
        throw NetworkError.invalidResponse
    }
    
    func setData<T: Encodable>(_ data: T) {
        mockData = try? JSONEncoder().encode(data)
    }
    
    func setError(_ error: Error) {
        mockError = error
    }
}

