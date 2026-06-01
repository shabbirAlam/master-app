import SwiftUI

extension AppRoute {
    @ViewBuilder
    func destination(container: AppDIContainer) -> some View {
        switch self {
        case .home(let details):
            details.destination(container: container)
        case .profile(let details):
            details.destination(container: container)
        }
    }
}
