import Foundation

/// Abstraction over GraphQL networking used by repositories.
protocol GraphQLNetworking: Sendable {
    /// Executes a GraphQL query and returns the decoded `data` payload.
    /// - Parameters:
    ///   - query: The GraphQL query string.
    ///   - variables: Optional query variables.
    /// - Returns: The decoded `data` object of the requested type.
    /// - Throws: `NetworkError` for invalid URLs, responses, status codes, or decoding failures.
    func fetch<T: Decodable>(query: String, variables: [String: AnyEncodable]?) async throws -> T
}

/// Default `GraphQLNetworking` implementation posting JSON-encoded queries
/// over `URLSession` with cancellation and status-code validation.
final class GraphQLNetworkingImpl: GraphQLNetworking {
    private let session: URLSession
    private static let decoder = JSONDecoder()
    /// The GraphQL server endpoint URL.
    private let url: URL?

    /// Creates a GraphQL client.
    /// - Parameters:
    ///   - session: The URL session to use (defaults to `.shared`).
    ///   - url: The endpoint URL; defaults to `ApiConfig.graphQLBaseURL`.
    init(session: URLSession = .shared, url: URL? = nil) {
        self.session = session
        self.url = url ?? URL(string: ApiConfig.graphQLBaseURL)
    }

    /// Executes a GraphQL query via HTTP POST.
    ///
    /// - Parameters:
    ///   - query: The GraphQL query string.
    ///   - variables: Optional query variables.
    /// - Returns: The decoded `data` field of the GraphQL response.
    /// - Throws: `CancellationError` if the task was cancelled,
    ///   `NetworkError.invalidURL` when no endpoint is configured,
    ///   `NetworkError.invalidResponse` for non-HTTP responses,
    ///   `NetworkError.badStatusCode` for non-2xx statuses, or
    ///   `NetworkError.decodingError` when the payload cannot be decoded.
    func fetch<T: Decodable>(query: String, variables: [String: AnyEncodable]? = nil) async throws -> T {
        try Task.checkCancellation()

        guard let url else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GraphQLRequest(query: query, variables: variables)
        request.httpBody = try JSONEncoder().encode(body)

        AppLogger.network.log("GraphQL request URL: \(url.absoluteString)")
        AppLogger.network.log("GraphQL query: \(query)")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            AppLogger.network.log("GraphQL bad status code: \(httpResponse.statusCode)", .error)
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }

        if let json = String(data: data, encoding: .utf8) {
            AppLogger.network.log("GraphQL response: \(json)")
        }

        do {
            return try Self.decoder.decode(GraphQLResponse<T>.self, from: data).data
        } catch {
            AppLogger.network.log("GraphQL decode error: \(error.localizedDescription)", .error)
            throw NetworkError.decodingError
        }
    }
}
