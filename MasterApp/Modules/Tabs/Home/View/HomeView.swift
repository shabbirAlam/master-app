//
//  HomeView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: Router
    
    private let vm: HomeViewModel
    private let themeManager = ThemeManager.shared
    
    init(vm: HomeViewModel = HomeViewModel()) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack {
            themeManager.background.edgesIgnoringSafeArea(.all)
            
            List(vm.items, id: \.self){ item in
                Button {
                    if let route = vm.route(for: item) {
                        router.push(route)
                    }
                } label: {
                    HStack {
                        Text(item.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(themeManager.textPrimary)
                }
                .accessibilityIdentifier(item.name)
            }
            .accessibilityIdentifier("home_view")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(Router())
}
