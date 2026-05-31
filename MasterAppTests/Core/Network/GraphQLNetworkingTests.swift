import Foundation
import Testing
@testable import MasterApp

@MainActor
struct GraphQLNetworkingTests {
    @Test
    func fetchSuccess() async throws {
        let url = URL(string: "https://test-gql-success.trevorblades.com/")!

        let responseData = """
        {"data": {"countries": [{"code": "IN", "name": "India", "capital": "Delhi"}]}}
        """.data(using: .utf8)!

        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        MockURLProtocol.updateTestURL(url, value: (responseData, response, nil))

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let networking = GraphQLNetworkingImpl(session: session, url: url)

        let result: CountriesResponse = try await networking.fetch(
            query: "query { countries { code name capital } }",
            variables: nil
        )

        #expect(result.countries.count == 1)
        #expect(result.countries[0].name == "India")
        #expect(result.countries[0].code == "IN")

        MockURLProtocol.removeTestURL(url)
    }

    @Test
    func fetchBadStatus() async {
        let url = URL(string: "https://test-gql-error.trevorblades.com/")!

        let response = HTTPURLResponse(
            url: url,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        MockURLProtocol.updateTestURL(url, value: (Data(), response, nil))

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let networking = GraphQLNetworkingImpl(session: session, url: url)

        do {
            let _: CountriesResponse = try await networking.fetch(
                query: "query { countries { code name capital } }",
                variables: nil
            )
            Issue.record("Expected failure")
        } catch let error as NetworkError {
            switch error {
            case .badStatusCode(let code):
                #expect(code == 500)
            default:
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        MockURLProtocol.removeTestURL(url)
    }

    @Test
    func fetchWithVariables() async throws {
        let url = URL(string: "https://test-gql-variables.trevorblades.com/")!

        let responseData = """
        {"data": {"country": {"code": "IN", "name": "India", "capital": "Delhi"}}}
        """.data(using: .utf8)!

        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        MockURLProtocol.updateTestURL(url, value: (responseData, response, nil))

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let networking = GraphQLNetworkingImpl(session: session, url: url)

        let result: CountryWrapper = try await networking.fetch(
            query: "query GetCountry($code: ID!) { country(code: $code) { name capital code } }",
            variables: ["code": AnyEncodable("IN")]
        )

        #expect(result.country.name == "India")
        #expect(result.country.code == "IN")

        MockURLProtocol.removeTestURL(url)
    }

    @Test
    func fetchInvalidResponse() async {
        let url = URL(string: "https://test-gql-invalid.trevorblades.com/")!

        let fakeResponse = URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        MockURLProtocol.updateTestURL(url, value: (Data(), fakeResponse, nil))

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let networking = GraphQLNetworkingImpl(session: session, url: url)

        do {
            let _: CountriesResponse = try await networking.fetch(
                query: "query { countries { code name capital } }",
                variables: nil
            )
            Issue.record("Expected failure")
        } catch let error as NetworkError {
            switch error {
            case .invalidResponse:
                #expect(true)
            default:
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        MockURLProtocol.removeTestURL(url)
    }

    @Test
    func fetchDecodingError() async {
        let url = URL(string: "https://test-gql-decode-error.trevorblades.com/")!

        let invalidData = """
        {"countries": []}
        """.data(using: .utf8)!

        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        MockURLProtocol.updateTestURL(url, value: (invalidData, response, nil))

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let networking = GraphQLNetworkingImpl(session: session, url: url)

        do {
            let _: CountriesResponse = try await networking.fetch(
                query: "query { countries { code name capital } }",
                variables: nil
            )
            Issue.record("Expected failure")
        } catch is DecodingError {
            #expect(true)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        MockURLProtocol.removeTestURL(url)
    }
}
