import Testing
@testable import MasterApp

@MainActor
struct AIChatViewModelTests {

    @Test func startNewSessionCreatesSession() {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)

        #expect(vm.sessions.isEmpty)
        #expect(vm.selectedSession == nil)

        vm.startNewSession()

        #expect(vm.sessions.count == 1)
        #expect(vm.selectedSession != nil)
        #expect(vm.selectedSession?.title == "New Chat")
        #expect(vm.selectedSession?.messages.isEmpty == true)
    }

    @Test func selectSessionChangesSelection() {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)

        vm.startNewSession()
        vm.startNewSession()
        let firstId = vm.sessions[0].id
        let secondId = vm.sessions[1].id

        vm.selectSession(firstId)
        #expect(vm.selectedSessionId == firstId)

        vm.selectSession(secondId)
        #expect(vm.selectedSessionId == secondId)
    }

    @Test func deleteSessionRemovesIt() {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)

        vm.startNewSession()
        vm.startNewSession()
        let id = vm.sessions[0].id

        vm.deleteSession(id)

        #expect(vm.sessions.contains(where: { $0.id == id }) == false)
        #expect(vm.sessions.count == 1)
    }

    @Test func deleteSessionClearsSelectionWhenCurrent() {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)

        vm.startNewSession()
        let id = vm.selectedSessionId!

        vm.deleteSession(id)

        #expect(vm.selectedSession == nil)
    }

    @Test func deleteSessionsAtOffsets() {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)

        vm.startNewSession()
        vm.startNewSession()
        vm.startNewSession()

        #expect(vm.sessions.count == 3)

        vm.deleteSessions(at: [0])

        #expect(vm.sessions.count == 2)
    }

    @Test func sendMessageAppendsUserAndAssistantMessages() async {
        let mock = MockAIChatService(mockResponse: "Hello, user!")
        let vm = AIViewModel(service: mock)
        vm.startNewSession()

        vm.currentInput = "Hello"

        await vm.sendMessage()

        let session = vm.selectedSession!
        #expect(session.messages.count == 2)
        #expect(session.messages[0].role == .user)
        #expect(session.messages[0].content == "Hello")
        #expect(session.messages[1].role == .assistant)
        #expect(session.messages[1].content == "Hello, user!")
    }

    @Test func sendMessageClearsInput() async {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)
        vm.startNewSession()
        vm.currentInput = "test"

        await vm.sendMessage()

        #expect(vm.currentInput.isEmpty)
    }

    @Test func sendMessageWithEmptyInputDoesNothing() async {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)

        vm.currentInput = "   "

        await vm.sendMessage()

        #expect(vm.selectedSession == nil)
    }

    @Test func sendMessageWithoutSessionDoesNothing() async {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)
        vm.currentInput = "hello"

        await vm.sendMessage()

        #expect(vm.selectedSession == nil)
    }

    @Test func sendMessageUpdatesTitleAfterFirstMessage() async {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)
        vm.startNewSession()

        vm.currentInput = "What is Swift?"
        await vm.sendMessage()

        #expect(vm.selectedSession?.title == "What is Swift?")
    }

    @Test func sendMessageHandlesError() async {
        struct TestError: Error, Equatable {}
        let mock = MockAIChatService(mockResponse: "")
        mock.setError(TestError())
        let vm = AIViewModel(service: mock)
        vm.startNewSession()
        vm.currentInput = "hello"

        await vm.sendMessage()

        #expect(vm.errorMsg != nil)
        #expect(vm.isLoading == false)
    }

    @Test func loadingStateDuringMessage() async {
        let mock = MockAIChatService(mockResponse: "response", delay: 100_000_000)
        let vm = AIViewModel(service: mock)
        vm.startNewSession()
        vm.currentInput = "hello"

        let task = Task { await vm.sendMessage() }

        try? await Task.sleep(nanoseconds: 10_000_000)
        #expect(vm.isLoading == true)

        await task.value
        #expect(vm.isLoading == false)
    }

    @Test func sortedSessionsMostRecentFirst() {
        let mock = MockAIChatService()
        let vm = AIViewModel(service: mock)

        vm.startNewSession()
        vm.startNewSession()

        let sorted = vm.sortedSessions
        #expect(sorted[0].updatedAt >= sorted[1].updatedAt)
    }

    @Test func persistenceAcrossInstances() {
        let mock = MockAIChatService()
        let vm1 = AIViewModel(service: mock)
        vm1.startNewSession()
        vm1.startNewSession()

        let vm2 = AIViewModel(service: mock)
        #expect(vm2.sessions.count == 2)
    }

    @Test func mockAIChatServiceGenerateResponse() async throws {
        let mock = MockAIChatService(mockResponse: "Test response")

        let response = try await mock.generateResponse(for: "Hello")

        #expect(response == "Test response")
    }

    @Test func mockAIChatServiceSaveAndLoad() {
        let mock = MockAIChatService()
        let session = ChatSession(title: "Test")
        mock.saveSessions([session])

        let loaded = mock.loadSessions()

        #expect(loaded.count == 1)
        #expect(loaded[0].title == "Test")
    }
}
