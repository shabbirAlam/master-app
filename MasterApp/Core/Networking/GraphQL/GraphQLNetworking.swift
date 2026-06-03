import Foundation

protocol GraphQLNetworking: Sendable {
    func fetch<T: Decodable>(query: String, variables: [String: AnyEncodable]?) async throws -> T
}

final class GraphQLNetworkingImpl: GraphQLNetworking {
    private let session: URLSession
    private static let decoder = JSONDecoder()
    private let url: URL?

    init(session: URLSession = .shared, url: URL? = nil) {
        self.session = session
        self.url = url ?? URL(string: ApiConfig.graphQLBaseURL)
    }

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
