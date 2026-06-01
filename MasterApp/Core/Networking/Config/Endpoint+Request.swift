import Foundation
import os

extension Endpoint {
    func request(with encoder: JSONEncoder) throws -> URLRequest {
        guard let url = URL(string: baseURL),
              var components = URLComponents(url: url.appendingPathComponent(path),
                                             resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        if let body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch let error as EncodingError {
                AppLogger.network.error("Encoding error: \(error.localizedDescription, privacy: .public)")
                throw NetworkError.encodingError
            } catch {
                AppLogger.network.error("Unknown encoding error: \(error.localizedDescription, privacy: .public)")
                throw NetworkError.encodingError
            }
        }

        headers?.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }

        return request
    }
}
