import Foundation
import os

final class MockURLProtocol: URLProtocol {

    private static let testURLs = OSAllocatedUnfairLock(
        initialState: [URL: (data: Data?, response: URLResponse?, error: Error?)]()
    )

    static func set(_ url: URL, value: (data: Data?, response: URLResponse?, error: Error?)) {
        testURLs.withLock { $0[url] = value }
    }

    static func remove(_ url: URL) {
        testURLs.withLock { _ = $0.removeValue(forKey: url) }
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

        let value = Self.testURLs.withLock { $0[url] }

        if let error = value?.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = value?.response {
            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
        }

        if let data = value?.data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
