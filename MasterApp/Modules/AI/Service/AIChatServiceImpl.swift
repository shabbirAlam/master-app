import Foundation
import FoundationModels

@available(iOS 26.0, *)
final class AIChatServiceImpl: AIChatService {
    private let session: LanguageModelSession
    private let defaults: UserDefaults
    private let backgroundQueue: DispatchQueue

    init(session: LanguageModelSession = LanguageModelSession(), defaults: UserDefaults = .standard, backgroundQueue: DispatchQueue = .global(qos: .background)) {
        self.session = session
        self.defaults = defaults
        self.backgroundQueue = backgroundQueue
    }

    func generateResponse(for query: String) async throws -> String {
        let response = try await session.respond(to: query)
        debugPrint(response)
        return response.content
    }

    private static let sessionsKey = "ai_chat_sessions"

    func loadSessions() -> [ChatSession] {
        guard let data = defaults.data(forKey: Self.sessionsKey) else { return [] }
        return (try? JSONDecoder().decode([ChatSession].self, from: data)) ?? []
    }

    func saveSessions(_ sessions: [ChatSession]) {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        defaults.set(data, forKey: Self.sessionsKey)
    }
}
