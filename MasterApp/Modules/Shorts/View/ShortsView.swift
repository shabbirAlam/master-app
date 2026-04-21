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
            
            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<viewModel.urls.count, id: \.self) { ind in
                            if let url = URL(string: viewModel.urls[ind]) {
                                VideoView(url: url)
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ShortsView()
}
