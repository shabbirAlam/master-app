import Foundation

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

        AppLogger.log("Request URL: \(request.url?.absoluteString ?? "nil")", level: .debug)
        AppLogger.log("Method: \(request.httpMethod ?? "")", level: .debug)

        if let httpBody = request.httpBody,
           let json = String(data: httpBody, encoding: .utf8) {
            AppLogger.log("Body: \(json)", level: .debug)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            AppLogger.log("Bad status code: \(httpResponse.statusCode)", level: .error)
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }

        if let json = String(data: data, encoding: .utf8) {
            AppLogger.log("Response: \(json)", level: .debug)
        }

        do {
            return try Self.decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            AppLogger.log("Decoding error: \(error.localizedDescription)", level: .error)
            throw NetworkError.decodingError
        } catch {
            AppLogger.log("Unknown decoding error: \(error.localizedDescription)", level: .error)
            throw NetworkError.decodingError
        }
    }
}

