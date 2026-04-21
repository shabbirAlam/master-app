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
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                DashboardView()
                    .environmentObject(router)
                    .navigationDestination(for: AppRoute.self) { route in
                        route.destination()
                    }
            }
        }
    }
}
