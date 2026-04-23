//
//  AppRouteImpl.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

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

extension HomeRoute {
    @ViewBuilder
    fileprivate func destinations() -> some View {
        switch self {
            case .todo:
                TodoBuilder.makeTodoView()
        }
    }
}

extension ProfileRoute {
    @ViewBuilder
    fileprivate func destinations() -> some View {
        switch self {
            case .editProfile:
                ProfileDetailsView()
        }
    }
}
