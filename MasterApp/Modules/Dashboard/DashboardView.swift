//
//  DashboardView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var scheme
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack(path: $router.path) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                
                ShortsView()
                    .tabItem {
                        Image(systemName: "video.bubble")
                        Text("Shorts")
                    }
                    .tag(1)
                    .background(Color.black.opacity(0.5))
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(2)
            }
            .navigationDestination(for: AppRoute.self) { route in
                route.destination()
            }
            .onAppear {
                themeManager.update(for: scheme)
            }
            .onChange(of: scheme) { newValue in
                themeManager.update(for: newValue)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(Router())
        .environmentObject(ThemeManager())
}
