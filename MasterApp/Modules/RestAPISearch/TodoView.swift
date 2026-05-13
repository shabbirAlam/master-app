//
//  TodoView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

enum TodoBuilder {
    static func build() -> TodoView {
        let service = TodoServiceImpl(networking: AppDIContainer.shared.networking)
        let vm = TodoViewModel(service: service)
        return TodoView(vm: vm)
    }
}

struct TodoView: View {
    @StateObject private var vm: TodoViewModel
    private let themeManager = ThemeManager.shared
    
    init(vm: TodoViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            themeManager.background.edgesIgnoringSafeArea(.all)
            
            VStack {
                TextField("Search...", text: $vm.searchedText)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                List(Array(vm.items.enumerated()), id: \.element.id) { index, item in
                    Text(item.title)
                        .accessibilityIdentifier("todo_label_\(index)")
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(themeManager.background)
            }
            
            if vm.isLoading {
                ProgressView()
            } else if let msg = vm.errorMsg {
                Text(msg)
            } else if vm.items.isEmpty {
                Text("No data found")
            }
        }
        .navigationTitle("Todos")
        .task(id: vm.searchedText) {
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
