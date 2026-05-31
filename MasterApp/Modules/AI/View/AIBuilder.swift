import SwiftUI

enum AIBuilder {
    @ViewBuilder
    static func build() -> some View {
        if AIAvailability.isEnabled(), #available(iOS 26.0, *) {
            AIView(vm: AIViewModel(service: AIChatServiceImpl()))
        } else {
            AIUnAvailableView()
        }
    }
}
