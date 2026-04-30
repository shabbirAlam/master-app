//
//  AppRouteImpl.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

extension AppRoute {
    @ViewBuilder
    func destination(with container: AppDIContainer) -> some View {
        switch self {
        case .home(let details):
            details.destinations(container: container)
        case .profile(let details):
            details.destinations(container: container)
        }
    }
}

extension HomeRoute {
    @ViewBuilder
    fileprivate func destinations(container: AppDIContainer) -> some View {
        switch self {
        case .todo:
            TodoBuilder.build(with: container)
        case .ai:
            AIBuilder.build()
        }
    }
}

extension ProfileRoute {
    @ViewBuilder
    fileprivate func destinations(container: AppDIContainer) -> some View {
        switch self {
        case .editProfile:
            ProfileDetailsView()
        }
    }
}
