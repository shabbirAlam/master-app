//
//  AppRoute.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Foundation

enum AppRoute: Hashable {
    case home(type: HomeRoute)
    case profile(type: ProfileRoute)
}

enum ProfileRoute: Hashable {
    case editProfile
}

enum HomeRoute: Hashable {
    case todo
}
