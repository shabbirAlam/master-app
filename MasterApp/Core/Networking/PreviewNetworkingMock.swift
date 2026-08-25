import Foundation

#if DEBUG
/// Debug-only `Networking` mock returning canned data or errors,
/// intended for SwiftUI previews and snapshot tests.
final class PreviewNetworkingMock: Networking {
    private var mockData: Data?
    private var mockError: Error?

    /// Returns the configured mock payload, or throws the configured error.
    func request<T : Decodable>(_ endpoint: Endpoint) async throws -> T {
        if let mockError {
            throw mockError
        }

        if let mockData {
            return try JSONDecoder().decode(T.self, from: mockData)
        }

        throw NetworkError.invalidResponse
    }

    /// Configures the raw JSON payload returned by subsequent requests.
    func setData(_ data: Data) {
        mockData = data
    }

    /// Encodes and configures the payload returned by subsequent requests.
    func setData<T: Encodable>(_ data: T) {
        mockData = try? JSONEncoder().encode(data)
    }

    /// Configures the error thrown by subsequent requests.
    func setError(_ error: Error) {
        mockError = error
    }
}
#endif
