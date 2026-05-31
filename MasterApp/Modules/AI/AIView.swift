import SwiftUI

struct AIView: View {
    @StateObject private var vm: AIViewModel
    private let themeManager = ThemeManager.shared

    init(vm: AIViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            themeManager.background.ignoresSafeArea()

            if vm.selectedSession != nil {
                chatContent
            } else {
                sessionListView
            }
        }
        .navigationTitle(vm.selectedSession?.title ?? "AI Chat")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.selectedSession != nil {
                    Button("History") {
                        vm.selectedSessionId = nil
                    }
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                if vm.selectedSession == nil {
                    Button("New Chat") {
                        vm.startNewSession()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var chatContent: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.selectedSession?.messages ?? []) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollToLastMessage(proxy)
                }
                .onChange(of: vm.selectedSession?.messages.count) { _ in
                    scrollToLastMessage(proxy)
                }
            }

            if let error = vm.errorMsg {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            HStack(spacing: 8) {
                TextField("Type a message...", text: $vm.currentInput, axis: .vertical)
                    .lineLimit(1...5)
                    .textFieldStyle(.roundedBorder)
                    .disabled(vm.isLoading)
                    .submitLabel(.send)
                    .onSubmit {
                        Task { await vm.sendMessage() }
                    }

                Button {
                    Task { await vm.sendMessage() }
                } label: {
                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                }
                .disabled(vm.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isLoading)
            }
            .padding()
        }
    }

    private func scrollToLastMessage(_ proxy: ScrollViewProxy) {
        if let last = vm.selectedSession?.messages.last {
            withAnimation {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }

    private var sessionListView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(themeManager.textPrimary.opacity(0.3))

            Text("AI Chat")
                .font(.title2)
                .foregroundColor(themeManager.textPrimary)

            Text("Start a new conversation or select one from history.")
                .font(.subheadline)
                .foregroundColor(themeManager.textPrimary.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if vm.sessions.isEmpty {
                Button("Start New Chat") {
                    vm.startNewSession()
                }
                .buttonStyle(.borderedProminent)
            }

            if !vm.sessions.isEmpty {
                List {
                    Section("Recent Chats") {
                        ForEach(vm.sortedSessions) { session in
                            Button {
                                vm.selectSession(session.id)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title)
                                        .foregroundColor(themeManager.textPrimary)
                                        .lineLimit(1)
                                    Text(session.updatedAt.formatted())
                                        .font(.caption)
                                        .foregroundColor(themeManager.textPrimary.opacity(0.5))
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    vm.deleteSession(session.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete { offsets in
                            vm.deleteSessions(at: offsets)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}
