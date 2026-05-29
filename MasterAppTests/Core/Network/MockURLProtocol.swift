import Foundation
import os

final class MockURLProtocol: URLProtocol {

    private static let lock = OSAllocatedUnfairLock()
    private static nonisolated(unsafe) var _testURLs: [URL: (data: Data?, response: URLResponse?, error: Error?)] = [:]

    static func updateTestURL(_ url: URL, value: (data: Data?, response: URLResponse?, error: Error?)) {
        lock.withLock { _testURLs[url] = value }
    }

    static func removeTestURL(_ url: URL) {
        lock.withLock { _testURLs.removeValue(forKey: url) }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        let (data, response, error) = Self.lock.withLock { Self._testURLs[url] } ?? (nil, nil, nil)

        if let error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response {
            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
        }

        if let data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
