import Combine
import Foundation
import FoundationModels

// MARK: - Models

enum ChatRole: String, Codable, Sendable {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let role: ChatRole
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: ChatRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

struct ChatSession: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), title: String = "New Chat", messages: [ChatMessage] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Service

protocol AIChatService {
    func generateResponse(for query: String) async throws -> String
    func loadSessions() -> [ChatSession]
    func saveSessions(_ sessions: [ChatSession])
}

@available(iOS 26.0, *)
final class AIChatServiceImpl: AIChatService {
    private let session: LanguageModelSession
    private let defaults: UserDefaults

    init(session: LanguageModelSession = LanguageModelSession(), defaults: UserDefaults = .standard) {
        self.session = session
        self.defaults = defaults
    }

    func generateResponse(for query: String) async throws -> String {
        let response = try await session.respond(to: query)
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

// MARK: - ViewModel

@MainActor
final class AIViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var selectedSessionId: UUID?
    @Published var currentInput = ""
    @Published var isLoading = false
    @Published var errorMsg: String?

    private let service: AIChatService

    var selectedSession: ChatSession? {
        guard let id = selectedSessionId else { return nil }
        return sessions.first { $0.id == id }
    }

    var sortedSessions: [ChatSession] {
        sessions.sorted { $0.updatedAt > $1.updatedAt }
    }

    init(service: AIChatService) {
        self.service = service
        self.sessions = service.loadSessions()
        if selectedSessionId == nil {
            selectedSessionId = sessions.first?.id
        }
    }

    func startNewSession() {
        let session = ChatSession()
        sessions.insert(session, at: 0)
        selectedSessionId = session.id
        persistSessions()
    }

    func selectSession(_ id: UUID) {
        selectedSessionId = id
    }

    func deleteSession(_ id: UUID) {
        sessions.removeAll { $0.id == id }
        if selectedSessionId == id {
            selectedSessionId = sessions.first?.id
        }
        persistSessions()
    }

    func deleteSessions(at offsets: IndexSet) {
        let sorted = sortedSessions
        let idsToDelete = offsets.map { sorted[$0].id }
        sessions.removeAll { idsToDelete.contains($0.id) }
        if let current = selectedSessionId, idsToDelete.contains(current) {
            selectedSessionId = sessions.first?.id
        }
        persistSessions()
    }

    func sendMessage() async {
        let text = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let sessionId = selectedSessionId else { return }

        currentInput = ""

        let userMessage = ChatMessage(role: .user, content: text)
        appendMessage(userMessage, to: sessionId)

        if let idx = sessions.firstIndex(where: { $0.id == sessionId }),
           sessions[idx].messages.count == 1 {
            sessions[idx].title = String(text.prefix(60))
        }

        isLoading = true
        errorMsg = nil

        do {
            let response = try await service.generateResponse(for: text)
            let assistantMessage = ChatMessage(role: .assistant, content: response)
            appendMessage(assistantMessage, to: sessionId)
        } catch is CancellationError {
            return
        } catch {
            errorMsg = error.localizedDescription
        }

        isLoading = false
    }

    private func appendMessage(_ message: ChatMessage, to sessionId: UUID) {
        guard let idx = sessions.firstIndex(where: { $0.id == sessionId }) else { return }
        sessions[idx].messages.append(message)
        sessions[idx].updatedAt = Date()
        persistSessions()
    }

    private func persistSessions() {
        service.saveSessions(sessions)
    }
}
