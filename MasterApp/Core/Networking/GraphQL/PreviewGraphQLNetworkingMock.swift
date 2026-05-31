import Foundation

#if DEBUG
final class PreviewGraphQLNetworkingMock: GraphQLNetworking, Sendable {
    private var mockData: Data?
    private var mockError: Error?

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

    func setData<T: Encodable>(_ data: T) {
        mockData = try? JSONEncoder().encode(data)
    }

    func setError(_ error: Error) {
        mockError = error
    }
}
#endif
