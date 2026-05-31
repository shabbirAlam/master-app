import Foundation

protocol AIChatService {
    func generateResponse(for query: String) async throws -> String
    func loadSessions() -> [ChatSession]
    func saveSessions(_ sessions: [ChatSession])
}
