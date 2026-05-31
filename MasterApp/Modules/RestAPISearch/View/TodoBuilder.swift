import SwiftUI

enum TodoBuilder {
    static func build() -> TodoView {
        let container = AppDIContainer()
        let service = TodoServiceImpl(networking: container.networking)
        let vm = TodoViewModel(service: service)
        return TodoView(vm: vm)
    }
}
