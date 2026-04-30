//
//  TodoView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

enum TodoBuilder {
    static func build(with appDIContainer: AppDIContainer) -> TodoView {
        let service = TodoServiceImpl(networking: appDIContainer.networking)
        let vm = TodoViewModel(service: service)
        return TodoView(vm: vm)
    }
}

struct TodoView: View {
    @StateObject private var vm: TodoViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    init(vm: TodoViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            themeManager.current.background.edgesIgnoringSafeArea(.all)
            
            List(vm.items.indices, id: \.self) { ind in
                Text(vm.items[ind].title) .accessibilityIdentifier("todo_label_\(ind)")
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
        .task {
            if vm.items.isEmpty {
                await vm.fetchTodos()
            }
        }
    }
}

#Preview {
    let mock = PreviewNetworkingMock()
    mock.setData([Todo(userId: 1, id: 1, title: "todo 1", body: "this is todo 1 body")])
    return TodoView(vm: TodoViewModel(
        service: TodoServiceImpl(networking: mock)))
    .environmentObject(ThemeManager())
}
