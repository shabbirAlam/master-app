//
//  MasterAppApp.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

@main
struct MasterAppApp: App {
    @StateObject private var router = Router()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(router)
                .environmentObject(themeManager)
        }
    }
}
