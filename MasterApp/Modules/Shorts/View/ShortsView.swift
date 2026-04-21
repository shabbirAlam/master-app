//
//  ShortsView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

struct ShortsView: View {
    @StateObject var viewModel = ShortsViewModel()

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea(edges: .top)
            
            VideoView(url: URL(string: "https://www.w3schools.com/html/mov_bbb.mp4")!)
                .ignoresSafeArea(edges: .top)
        }
    }
}

#Preview {
    ShortsView()
}
