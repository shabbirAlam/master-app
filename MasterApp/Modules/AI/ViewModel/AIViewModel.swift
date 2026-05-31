import Combine
import Foundation

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
        defer { isLoading = false }

        do {
            let response = try await service.generateResponse(for: text)
            let assistantMessage = ChatMessage(role: .assistant, content: response)
            appendMessage(assistantMessage, to: sessionId)
        } catch is CancellationError {
            return
        } catch {
            errorMsg = error.localizedDescription
        }
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
