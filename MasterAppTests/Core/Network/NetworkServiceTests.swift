@preconcurrency import Foundation
import Testing
@preconcurrency @testable import MasterApp

private func makeMockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

@MainActor
private struct TestEndpointWithPOSTBody: Endpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod = .POST
    let headers: [String: String]? = ["Content-Type": "application/json"]
    let queryItems: [URLQueryItem]? = nil
    let bodyData: Data?
    let timeout: TimeInterval = 30

    var body: Encodable? { bodyData }

    init(baseURL: String, path: String) {
        self.baseURL = baseURL
        self.path = path
        self.bodyData = Data()
    }
}

@MainActor
private struct TestEndpoint: Endpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod = .GET
    let headers: [String: String]? = nil
    let queryItems: [URLQueryItem]? = nil
    let bodyData: Data?
    let timeout: TimeInterval = 30

    var body: Encodable? { bodyData }

    init(baseURL: String, path: String) {
        self.baseURL = baseURL
        self.path = path
        self.bodyData = nil
    }
}

@MainActor
struct NetworkServiceTests {
    @Test
    func requestSuccess() async throws {
        let endpoint = TestEndpoint(baseURL: "https://rest-test1.com", path: "posts")
        let expectedURL = URL(string: "https://rest-test1.com/posts")!

        let mockUser = Todo(userId: 1, id: 1, title: "John", body: "todo body")
        let data = try JSONEncoder().encode(mockUser)

        let response = HTTPURLResponse(
            url: expectedURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        MockURLProtocol.set(expectedURL, value: (data, response, nil))

        let config = makeMockSession().configuration
        let service = NetworkingImpl(configuration: config)

        let result: Todo = try await service.request(endpoint)

        #expect(result.userId == 1)
        #expect(result.title == "John")

        MockURLProtocol.remove(expectedURL)
    }

    @Test
    func requestBadStatus() async {
        let endpoint = TestEndpoint(baseURL: "https://rest-test2.com", path: "items")
        let expectedURL = URL(string: "https://rest-test2.com/items")!

        let response = HTTPURLResponse(
            url: expectedURL,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )!

        MockURLProtocol.set(expectedURL, value: (Data(), response, nil))

        let config = makeMockSession().configuration
        let service = NetworkingImpl(configuration: config)

        do {
            let _: Todo = try await service.request(endpoint)
            Issue.record("Expected failure, but succeeded")
        } catch let error as NetworkError {
            switch error {
                case .badStatusCode(let code):
                    #expect(code == 400)
                default:
                    Issue.record("Unexpected error type: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }

        MockURLProtocol.remove(expectedURL)
    }

    @Test
    func requestInvalidResponse() async {
        let endpoint = TestEndpoint(baseURL: "https://rest-test3.com", path: "data")
        let expectedURL = URL(string: "https://rest-test3.com/data")!

        let fakeResponse = URLResponse(
            url: expectedURL,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        MockURLProtocol.set(expectedURL, value: (Data(), fakeResponse, nil))

        let config = makeMockSession().configuration
        let service = NetworkingImpl(configuration: config)

        do {
            let _: Todo = try await service.request(endpoint)
            Issue.record("Expected failure, but succeeded")
        } catch let error as NetworkError {
            switch error {
                case .invalidResponse:
                    #expect(true)
                default:
                    Issue.record("Unexpected error type: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
        MockURLProtocol.remove(expectedURL)
    }

    @Test
    func requestDecodingError() async {
        let endpoint = TestEndpoint(baseURL: "https://rest-decode-error.com", path: "data")
        let expectedURL = URL(string: "https://rest-decode-error.com/data")!

        let invalidData = """
        {"invalid_field": "value"}
        """.data(using: .utf8)!

        let response = HTTPURLResponse(
            url: expectedURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        MockURLProtocol.set(expectedURL, value: (invalidData, response, nil))

        let config = makeMockSession().configuration
        let service = NetworkingImpl(configuration: config)

        do {
            let _: Todo = try await service.request(endpoint)
            Issue.record("Expected decoding error but succeeded")
        } catch let error as NetworkError {
            switch error {
            case .decodingError:
                #expect(true)
            default:
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        MockURLProtocol.remove(expectedURL)
    }

    @Test
    func requestWithPOSTBody() async throws {
        let endpoint = TestEndpointWithPOSTBody(
            baseURL: "https://rest-post.com",
            path: "submit"
        )
        let expectedURL = URL(string: "https://rest-post.com/submit")!

        let mockData = try JSONEncoder().encode(Todo(userId: 1, id: 1, title: "posted", body: "body"))

        let response = HTTPURLResponse(
            url: expectedURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        MockURLProtocol.set(expectedURL, value: (mockData, response, nil))

        let config = makeMockSession().configuration
        let service = NetworkingImpl(configuration: config)

        let result: Todo = try await service.request(endpoint)

        #expect(result.title == "posted")

        MockURLProtocol.remove(expectedURL)
    }

    @Test
    func requestNetworkError() async {
        let endpoint = TestEndpoint(baseURL: "https://rest-network-error.com", path: "data")
        let expectedURL = URL(string: "https://rest-network-error.com/data")!

        MockURLProtocol.set(expectedURL, value: (nil, nil, URLError(.notConnectedToInternet)))

        let config = makeMockSession().configuration
        let service = NetworkingImpl(configuration: config)

        do {
            let _: Todo = try await service.request(endpoint)
            Issue.record("Expected network error but succeeded")
        } catch let error as URLError {
            #expect(error.code == .notConnectedToInternet)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        MockURLProtocol.remove(expectedURL)
    }
}
