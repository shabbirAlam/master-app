import Foundation

#if DEBUG
/// Debug-only `GraphQLNetworking` mock returning canned data or errors,
/// intended for SwiftUI previews and snapshot tests.
final class PreviewGraphQLNetworkingMock: GraphQLNetworking, Sendable {
    private var mockData: Data?
    private var mockError: Error?

    /// Returns the configured mock payload, or throws the configured error.
    func fetch<T: Decodable>(query: String, variables: [String: AnyEncodable]? = nil) async throws -> T {
        if let mockError {
            throw mockError
        }

        if let mockData {
            let data = try JSONDecoder().decode(T.self, from: mockData)
            return data
        }
        throw NetworkError.unknown
    }

    /// Configures the raw JSON payload returned by subsequent fetches.
    func setData(_ data: Data) {
        mockData = data
    }

    /// Encodes and configures the payload returned by subsequent fetches.
    func setData<T: Encodable>(_ data: T) {
        mockData = try? JSONEncoder().encode(data)
    }

    /// Configures the error thrown by subsequent fetches.
    func setError(_ error: Error) {
        mockError = error
    }
}
#endif
