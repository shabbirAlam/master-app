import Foundation
import Testing
@testable import MasterApp

struct NetworkErrorTests {
    @Test func invalidResponseDescription() {
        #expect(NetworkError.invalidResponse.errorDescription == "Server is not responding properly")
    }

    @Test func unauthorizedDescription() {
        #expect(NetworkError.badStatusCode(401).errorDescription == "Unauthorized access")
    }

    @Test func serverErrorDescription() {
        #expect(NetworkError.badStatusCode(500).errorDescription == "Server error, please try again later.")
        #expect(NetworkError.badStatusCode(599).errorDescription == "Server error, please try again later.")
    }

    @Test func defaultStatusCodeDescription() {
        #expect(NetworkError.badStatusCode(300).errorDescription == "Request failed (300)")
        #expect(NetworkError.badStatusCode(418).errorDescription == "Request failed (418)")
    }

    @Test func genericErrorDescriptions() {
        #expect(NetworkError.unknown.errorDescription == "Something went wrong, please try again later.")
        #expect(NetworkError.decodingError.errorDescription == "Something went wrong, please try again later.")
        #expect(NetworkError.encodingError.errorDescription == "Something went wrong, please try again later.")
    }

    @Test func invalidURLDescription() {
        #expect(NetworkError.invalidURL.errorDescription == "Invalid URL")
    }
}

struct HomeFeaturesTests {
    @Test func names() {
        #expect(HomeFeatures.ai.name == "AI")
        #expect(HomeFeatures.secureView.name == "Secure View")
        #expect(HomeFeatures.restAPISearch.name == "Rest API Search")
        #expect(HomeFeatures.graphQLSearch.name == "GraphQL Search")
    }
}

struct GraphQLRequestTests {
    @Test func encodingWithVariables() throws {
        let request = GraphQLRequest(query: "query { test }", variables: ["key": AnyEncodable("value")])
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["query"] as? String == "query { test }")
        let variables = json?["variables"] as? [String: String]
        #expect(variables?["key"] == "value")
    }

    @Test func encodingNilVariables() throws {
        let request = GraphQLRequest(query: "query { test }", variables: nil)
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["query"] as? String == "query { test }")
        #expect(json?["variables"] == nil)
    }
}

struct GraphQLResponseTests {
    @Test func decoding() throws {
        let json = """
        {"data": {"country": {"name": "India", "code": "IN", "capital": "Delhi"}}}
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(GraphQLResponse<CountryWrapper>.self, from: json)
        #expect(response.data.country.name == "India")
        #expect(response.data.country.code == "IN")
        #expect(response.data.country.capital == "Delhi")
    }
}

struct AnyEncodableTests {
    @Test func encodingString() throws {
        let value = AnyEncodable("hello")
        let data = try JSONEncoder().encode(value)
        let str = String(data: data, encoding: .utf8)
        #expect(str == "\"hello\"")
    }

    @Test func encodingInt() throws {
        let value = AnyEncodable(42)
        let data = try JSONEncoder().encode(value)
        let str = String(data: data, encoding: .utf8)
        #expect(str == "42")
    }

    @Test func encodingBool() throws {
        let value = AnyEncodable(true)
        let data = try JSONEncoder().encode(value)
        let str = String(data: data, encoding: .utf8)
        #expect(str == "true")
    }

    @Test func encodingArray() throws {
        let value = AnyEncodable(["a", "b"])
        let data = try JSONEncoder().encode(value)
        let str = String(data: data, encoding: .utf8)
        #expect(str == "[\"a\",\"b\"]")
    }

    @Test func encodingDictionary() throws {
        let dict = ["key": AnyEncodable("value")]
        let data = try JSONEncoder().encode(dict)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: String]
        #expect(json?["key"] == "value")
    }
}

struct APIEndpointTests {
    @Test func defaultGETRequest() throws {
        let endpoint = APIEndpoint(baseURL: "https://example.com", path: "api/test")
        let request = try endpoint.request(with: JSONEncoder())

        #expect(request.url?.absoluteString == "https://example.com/api/test")
        #expect(request.httpMethod == "GET")
        #expect(request.timeoutInterval == 30)
    }

    @Test func requestWithQueryItems() throws {
        let endpoint = APIEndpoint(
            baseURL: "https://example.com",
            path: "search",
            queryItems: [URLQueryItem(name: "q", value: "test")]
        )
        let request = try endpoint.request(with: JSONEncoder())

        #expect(request.url?.absoluteString == "https://example.com/search?q=test")
    }

    @Test func requestWithPOSTBody() throws {
        let body = try JSONEncoder().encode(["key": "value"])
        let endpoint = APIEndpoint(
            baseURL: "https://example.com",
            path: "submit",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: body
        )
        let request = try endpoint.request(with: JSONEncoder())

        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.httpBody != nil)
    }

    @Test func invalidURL() {
        let endpoint = APIEndpoint(baseURL: "", path: "")
        #expect(throws: NetworkError.invalidURL) {
            try endpoint.request(with: JSONEncoder())
        }
    }

    @Test func requestWithBodyEncodingError() throws {
        struct FailingEncodable: Encodable {
            func encode(to encoder: Encoder) throws {
                throw EncodingError.invalidValue(self, .init(codingPath: [], debugDescription: "test"))
            }
        }
        struct TestEndpointWithBody: Endpoint {
            let baseURL: String = "https://example.com"
            let path: String = "test"
            let method: HTTPMethod = .POST
            let headers: [String: String]? = nil
            let queryItems: [URLQueryItem]? = nil
            let body: (any Encodable)? = FailingEncodable()
            let timeout: TimeInterval = 30
        }
        let endpoint = TestEndpointWithBody()
        #expect(throws: NetworkError.encodingError) {
            try endpoint.request(with: JSONEncoder())
        }
    }
}

struct ApiConfigTests {
    @Test func baseURL() {
        #expect(ApiConfig.baseURL == "https://dev-api.master.com")
    }

    @Test func graphQLBaseURL() {
        #expect(ApiConfig.graphQLBaseURL == "https://countries.trevorblades.com/")
    }

    @Test func todoBaseURL() {
        #expect(ApiConfig.todoBaseURL == "https://jsonplaceholder.typicode.com/")
    }
}

struct PreviewNetworkingMockTests {
    @Test func requestSuccess() async throws {
        let mock = PreviewNetworkingMock()
        mock.setData(Todo(userId: 1, id: 1, title: "test", body: "body"))
        let endpoint = APIEndpoint(baseURL: "https://example.com", path: "todos")
        let result: Todo = try await mock.request(endpoint)
        #expect(result.title == "test")
    }

    @Test func requestNoData() async {
        let mock = PreviewNetworkingMock()
        let endpoint = APIEndpoint(baseURL: "https://example.com", path: "todos")
        await #expect(throws: URLError.self) {
            let _: Todo = try await mock.request(endpoint)
        }
    }
}

struct PreviewGraphQLNetworkingMockTests {
    @Test func fetchSuccess() async throws {
        let mock = PreviewGraphQLNetworkingMock()
        let todo = Todo(userId: 1, id: 1, title: "test", body: "body")
        mock.setData(todo)
        let result: Todo = try await mock.fetch(query: "{ todos }")
        #expect(result.title == "test")
    }

    @Test func fetchError() async {
        let mock = PreviewGraphQLNetworkingMock()
        mock.setError(NetworkError.unknown)
        await #expect(throws: NetworkError.unknown) {
            let _: CountryWrapper = try await mock.fetch(query: "{ country }")
        }
    }

    @Test func fetchNoData() async {
        let mock = PreviewGraphQLNetworkingMock()
        await #expect(throws: URLError.self) {
            let _: Todo = try await mock.fetch(query: "{ todos }")
        }
    }
}
