import Foundation

extension Endpoint {
    /// Builds a `URLRequest` from this endpoint's configuration.
    ///
    /// - Parameter encoder: The JSON encoder used to serialize the body.
    /// - Returns: A fully configured URL request.
    /// - Throws: `NetworkError.invalidURL` when the base URL, path, or query
    ///   items cannot form a valid URL, or `NetworkError.encodingError` when
    ///   the body cannot be encoded.
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
                AppLogger.network.log("Encoding error: \(error.localizedDescription)", .error)
                throw NetworkError.encodingError
            } catch {
                AppLogger.network.log("Unknown encoding error: \(error.localizedDescription)", .error)
                throw NetworkError.encodingError
            }
        }

        headers?.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }

        return request
    }
}
