import Foundation

struct APIEndpoint: Endpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let queryItems: [URLQueryItem]?
    let body: Encodable?
    var timeout: TimeInterval

    init(baseURL: String = ApiConfig.baseURL,
         path: String,
         method: HTTPMethod = .GET,
         headers: [String: String]? = nil,
         queryItems: [URLQueryItem]? = nil,
         body: Encodable? = nil,
         timeout: TimeInterval = 30) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
        self.timeout = timeout
    }
}
