import SwiftUI

struct TodoView: View {
    @StateObject private var vm: TodoViewModel

    init(vm: TodoViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack {
                TextField("Search...", text: $vm.searchedText)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .onChange(of: vm.searchedText) { _ in
                        vm.filterSearch()
                    }

                List(Array(vm.items.enumerated()), id: \.element.id) { index, item in
                    Text(item.title)
                        .accessibilityIdentifier("todo_label_\(index)")
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }

            if vm.isLoading {
                ProgressView()
            } else if let msg = vm.errorMsg {
                Text(msg)
            } else if vm.items.isEmpty && !vm.isLoading {
                Text("No data found")
            }
        }
        .navigationTitle("Todos")
        .task {
            await vm.fetchTodos()
        }
    }
}

#Preview {
    let mock = PreviewNetworkingMock()
    mock.setData([Todo(userId: 1, id: 1, title: "todo 1", body: "this is todo 1 body")])
    return TodoView(vm: TodoViewModel(
        service: TodoServiceImpl(networking: mock)))
}
