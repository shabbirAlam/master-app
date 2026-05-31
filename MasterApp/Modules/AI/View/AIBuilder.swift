import SwiftUI

enum AIBuilder {
    @ViewBuilder
    static func build() -> some View {
        if #available(iOS 26.0, *) {
            let service = AIChatServiceImpl()
            let vm = AIViewModel(service: service)
            AIView(vm: vm)
        } else {
            AIUnAvailableView()
        }
    }
}
