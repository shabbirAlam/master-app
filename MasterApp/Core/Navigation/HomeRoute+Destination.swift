import SwiftUI

extension HomeRoute {
    @ViewBuilder
    func destinations() -> some View {
        switch self {
        case .secureView:
            SecureBuilder.build()
        case .graphQLSearch:
            CountryBuilder.build()
        case .restAPISearch:
            TodoBuilder.build()
        }
    }
}
