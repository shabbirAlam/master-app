import SwiftUI

extension ProfileRoute {
    @ViewBuilder
    func destination(container: AppDIContainer) -> some View {
        switch self {
        case .editProfile:
            ProfileDetailsView()
        }
    }
}
