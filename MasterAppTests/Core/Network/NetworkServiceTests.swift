//
//  NetworkServiceTests.swift
//  NetworkApp
//
//  Created by Md Shabbir Alam on 01/03/26.
//

import Foundation
import Testing
@testable import MasterApp

private func makeMockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

@Suite(.serialized)
struct NetworkServiceTests {
    @Test
    func requestSuccess() async throws {
        
        let url = URL(string: "https://test1.com")!
        
        let mockUser = Todo(id: 1, title: "John", completed: true, userId: 1)
        let data = try JSONEncoder().encode(mockUser)
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        MockURLProtocol.testURLs[url] = (data, response, nil)
        
        let service = NetworkServiceImpl(session: makeMockSession())
        
        let result: Todo = try await service.request(url)
        
        #expect(await result.userId == 1)
        #expect(await result.title == "John")
        
        MockURLProtocol.testURLs.removeValue(forKey: url)
    }
    
    @Test
    func requestBadStatus() async {
        
        let url = URL(string: "https://test2.com")!
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )!
        
        MockURLProtocol.testURLs[url] = (Data(), response, nil)
        
        let service = NetworkServiceImpl(session: makeMockSession())
        
        do {
            let _: Todo = try await service.request(url)
            Issue.record("Expected failure, but succeeded")
        } catch let error as NetworkError {
            switch error {
                case .badStatusCode(let code):
                    #expect(code == 400)
                    #expect(error.localizedDescription == "Something went wrong please try again later.")
                default:
                    Issue.record("Unexpected error type: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
        
        MockURLProtocol.testURLs.removeValue(forKey: url)
    }
    
    @Test
    func requestInvalidResponse() async {
        
        let url = URL(string: "https://test3.com")!
        
        let fakeResponse = URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        
        MockURLProtocol.testURLs[url] = (Data(), fakeResponse, nil)
        
        let service = NetworkServiceImpl(session: makeMockSession())
        
        do {
            let _: Todo = try await service.request(url)
            Issue.record("Expected failure, but succeeded")
        } catch let error as NetworkError {
            switch error {
                case .invalidResponse:
                    #expect(true)
                    #expect(error.localizedDescription == "Something went wrong please try again later.")
                default:
                    Issue.record("Unexpected error type: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
        MockURLProtocol.testURLs.removeValue(forKey: url)
    }
}
