import Foundation

/// Abstraction over REST networking used by repositories.
protocol Networking: Sendable {
    /// Performs an HTTP request described by the endpoint and decodes the response.
    /// - Parameter endpoint: The endpoint describing method, path, headers, and body.
    /// - Returns: The decoded response of the requested type.
    /// - Throws: `NetworkError` for invalid responses, bad status codes, or decoding failures.
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

/// Default `Networking` implementation built on `URLSession` with async/await,
/// request cancellation support, status-code validation, and snake-case decoding.
final class NetworkingImpl: Networking {
    private let session: URLSession
    /// Shared JSON decoder configured to convert snake_case keys to camelCase.
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()

    /// Creates a networking client with the given session configuration.
    ///
    /// The configuration is adjusted to wait for connectivity and use
    /// 30s request / 60s resource timeouts.
    /// - Parameter configuration: The URL session configuration (defaults to `.default`).
    init(configuration: URLSessionConfiguration = .default) {
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = URLSession(configuration: configuration)
    }

    /// Executes the endpoint's request, validates the HTTP status code, and decodes the body.
    ///
    /// - Parameter endpoint: The endpoint to request.
    /// - Returns: The decoded response.
    /// - Throws: `CancellationError` if the task was cancelled,
    ///   `NetworkError.invalidResponse` for non-HTTP responses,
    ///   `NetworkError.badStatusCode` for statuses outside 200..<300, and
    ///   `NetworkError.decodingError` when decoding fails.
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try Task.checkCancellation()

        let request = try endpoint.request(with: Self.encoder)

        AppLogger.network.log("Request URL: \(request.url?.absoluteString ?? "nil")")
        AppLogger.network.log("Method: \(request.httpMethod ?? "")")

        if let httpBody = request.httpBody,
           let json = String(data: httpBody, encoding: .utf8) {
            AppLogger.network.log("Body: \(json)")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            AppLogger.network.log("Bad status code: \(httpResponse.statusCode)", .error)
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }

        if let json = String(data: data, encoding: .utf8) {
            AppLogger.network.log("Response: \(json)")
        }

        do {
            return try Self.decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            AppLogger.network.log("Decoding error: \(error.localizedDescription)", .error)
            throw NetworkError.decodingError
        } catch {
            AppLogger.network.log("Unknown decoding error: \(error.localizedDescription)", .error)
            throw NetworkError.decodingError
        }
    }
}
