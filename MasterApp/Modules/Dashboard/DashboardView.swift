//
//  DashboardView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 1
    
    var body: some View {
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
        }
    }
}

#Preview {
    DashboardView()
}
