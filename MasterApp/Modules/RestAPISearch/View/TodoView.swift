import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel: TodoViewModel
    private let theme: Theme

    init(viewModel: TodoViewModel, theme: Theme = AppTheme.light) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.theme = theme
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                searchField
                    .padding(.vertical, 8)

                if let error = viewModel.errorMessage {
                    errorState(error)
                } else if viewModel.isLoading {
                    shimmerList
                } else if viewModel.items.isEmpty {
                    emptyState
                } else {
                    listView
                }
            }
        }
        .navigationTitle("Todos")
        .task {
            await viewModel.fetchTodos()
        }
    }

    private var searchField: some View {
        TextField("Search...", text: $viewModel.searchedText)
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
            .accessibilityIdentifier("todo_search")
            .onChange(of: viewModel.searchedText) {
                viewModel.filterSearch()
            }
    }

    private var listView: some View {
        List {
            ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                Text(item.title)
                    .accessibilityIdentifier("todo_label_\(index)")
                    .accessibilityLabel(item.title)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier("todo_list")
    }

    private var shimmerList: some View {
        ShimmerList()
            .accessibilityIdentifier("todo_loading")
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("No data found")
                .accessibilityIdentifier("todo_empty")
            Spacer()
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.red)
                .padding()
                .accessibilityIdentifier("todo_error")
            Spacer()
        }
    }
}

#if DEBUG
#Preview {
    let mock = PreviewNetworkingMock()
    mock.setData([Todo(userId: 1, id: 1, title: "todo 1", body: "this is todo 1 body")])
    return TodoView(
        viewModel: TodoViewModel(service: TodoServiceImpl(repository: TodoRepositoryImpl(networking: mock)))
    )
}
#endif
