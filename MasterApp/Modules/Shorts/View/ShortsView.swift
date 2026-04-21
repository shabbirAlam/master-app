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
                                    .applyContainerRelativeFrame(.vertical)
                            }
                        }
                    }
                }
                .applyScrollTargetBehavior()
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ShortsView()
}

extension View {
    @ViewBuilder
    func applyContainerRelativeFrame(_ axes: Axis.Set, alignment: Alignment = .center) -> some View {
        if #available(iOS 17.0, *) {
            self.containerRelativeFrame(axes, alignment: alignment)
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder
    func applyScrollTargetBehavior() -> some View {
        if #available(iOS 17.0, *) {
            self.scrollTargetBehavior(.paging)
        } else {
            self
        }
    }
}
