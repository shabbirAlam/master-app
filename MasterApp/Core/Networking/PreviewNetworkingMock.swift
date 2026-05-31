import Foundation

#if DEBUG
final class PreviewNetworkingMock: Networking {
    private var mockData: Data?
    private var mockError: Error?

    func request<T : Decodable>(_ endpoint: Endpoint) async throws -> T {
        if let mockError {
            throw mockError
        }

        if let mockData {
            return try JSONDecoder().decode(T.self, from: mockData)
        }

        throw NetworkError.invalidResponse
    }

    func setData<T: Encodable>(_ data: T) {
        mockData = try? JSONEncoder().encode(data)
    }

    func setError(_ error: Error) {
        mockError = error
    }
}
#endif
