//
//  DashboardView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var router: Router
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack(path: $router.path) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .secure()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(1)
            }
            .navigationDestination(for: AppRoute.self) { route in
                route.destination()
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(Router())
}
