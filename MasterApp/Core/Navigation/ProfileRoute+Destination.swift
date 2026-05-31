import SwiftUI

extension ProfileRoute {
    @ViewBuilder
    func destinations() -> some View {
        switch self {
        case .editProfile:
            ProfileDetailsView()
        }
    }
}
