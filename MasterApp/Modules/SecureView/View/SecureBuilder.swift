import SwiftUI

enum SecureBuilder {
    static func build(container: AppDIContainer) -> SecureView {
        SecureView(
            viewModel: SecureViewModel(),
            theme: container.theme
        )
    }
}
