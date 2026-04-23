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
#endif
