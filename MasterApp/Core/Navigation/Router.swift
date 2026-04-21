//
//  Router.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Combine
import SwiftUI

final class Router: ObservableObject {
    @Published var path: [AppRoute] = []
    
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

extension AppRoute {
    @ViewBuilder
    func destination() -> some View {
        switch self {
            case .home:
                HomeView()
            case .profile(let details):
                profileDestinations(for: details)
        }
    }
    
    @ViewBuilder
    private func profileDestinations(for route: ProfileRoute) -> some View {
        switch route {
            case .editProfile:
                ProfileDetailsView()
        }
    }
}
