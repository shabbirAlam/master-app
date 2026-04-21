//
//  ViewExtensions.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

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
