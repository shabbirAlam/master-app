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
    
    var body: some View {
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
                            .background(Color.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(16)
        }
    }
}

#Preview {
    HomeView()
}
