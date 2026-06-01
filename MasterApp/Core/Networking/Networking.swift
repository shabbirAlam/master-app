import Foundation
import os

// MARK: - Networking

protocol Networking: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class NetworkingImpl: Networking, @unchecked Sendable {

    private let session: URLSession
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()

    init(configuration: URLSessionConfiguration = .default,
         delegate: URLSessionDelegate? = nil) {
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try Task.checkCancellation()

        let request = try endpoint.request(with: Self.encoder)

        AppLogger.network.debug("Request URL: \(request.url?.absoluteString ?? "nil", privacy: .public)")
        AppLogger.network.debug("Method: \(request.httpMethod ?? "", privacy: .public)")

        if let httpBody = request.httpBody,
           let json = String(data: httpBody, encoding: .utf8) {
            AppLogger.network.debug("Body: \(json, privacy: .private)")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            AppLogger.network.error("Bad status code: \(httpResponse.statusCode, privacy: .public)")
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }

        if let json = String(data: data, encoding: .utf8) {
            AppLogger.network.debug("Response: \(json, privacy: .private)")
        }

        do {
            return try Self.decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            AppLogger.network.error("Decoding error: \(error.localizedDescription, privacy: .public)")
            throw NetworkError.decodingError
        } catch {
            AppLogger.network.error("Unknown decoding error: \(error.localizedDescription, privacy: .public)")
            throw NetworkError.decodingError
        }
    }
}
