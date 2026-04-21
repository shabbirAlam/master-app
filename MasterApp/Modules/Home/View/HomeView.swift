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
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16.0) {
                    ForEach(0..<vm.items.count, id: \.self) { ind in
                        Button {
                            if let route = vm.route(for: ind) {
                                router.push(route)
                            }
                        } label: {
                            Text(vm.items[ind])
                                .padding()
                                .frame(height: 48)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(themeManager.current.buttonPrimaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .foregroundStyle(themeManager.current.buttonPrimaryText)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(16)
            }
        }
    }
}

//#Preview {
//    HomeView()
//}
