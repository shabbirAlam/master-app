//
//  MockURLProtocol.swift
//  NetworkApp
//
//  Created by Md Shabbir Alam on 28/02/26.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    
    static var testURLs: [URL: (data: Data?, response: URLResponse?, error: Error?)] = [:]
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        
        guard let url = request.url else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        Task {
            let (data, response, error) = Self.testURLs[url] ?? (nil, nil, nil)
            
            if let error {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }
            
            if let response {
                client?.urlProtocol(
                    self,
                    didReceive: response,
                    cacheStoragePolicy: .notAllowed
                )
            }
            
            if let data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {}
}
