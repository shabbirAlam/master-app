//
//  HomeView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @EnvironmentObject var router: Router
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            themeManager.current.background.edgesIgnoringSafeArea(.all)
            
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
                    .foregroundStyle(themeManager.current.textPrimary)
                }
            }
        }
    }
}

//#Preview {
//    HomeView()
//}
