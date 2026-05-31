import Foundation

#if DEBUG
final class MockAIChatService: AIChatService {
    private var mockResponse: String
    private var storedSessions: [ChatSession] = []
    private var delay: UInt64
    private var mockError: Error?

    init(mockResponse: String = "This is a mock AI response.", delay: UInt64 = 300_000_000) {
        self.mockResponse = mockResponse
        self.delay = delay
    }

    func setError(_ error: Error?) {
        mockError = error
    }

    func generateResponse(for query: String) async throws -> String {
        if let mockError { throw mockError }
        try await Task.sleep(nanoseconds: delay)
        return mockResponse
    }

    func loadSessions() -> [ChatSession] {
        storedSessions
    }

    func saveSessions(_ sessions: [ChatSession]) {
        storedSessions = sessions
    }
}
#endif
