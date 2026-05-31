import SwiftUI

extension AppRoute {
    @ViewBuilder
    func destination() -> some View {
        switch self {
        case .home(let details):
            details.destinations()
        case .profile(let details):
            details.destinations()
        }
    }
}
