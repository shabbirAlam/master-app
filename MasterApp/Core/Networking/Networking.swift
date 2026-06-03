import Foundation

protocol Networking: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class NetworkingImpl: Networking {
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

    init(configuration: URLSessionConfiguration = .default) {
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = URLSession(configuration: configuration)
    }

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
