//
//  AIView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 29/04/26.
//

import SwiftUI

enum AIBuilder {
    @ViewBuilder
    static func build() -> some View {
        if #available(iOS 26.0, *) {
            AIView(vm: AIViewModel())
        } else {
            AIUnAvailableView()
        }
    }
}

@available(iOS 26.0, *)
struct AIView: View {
    @StateObject private var vm: AIViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    init(vm: AIViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        Text("Hello")
            .navigationTitle("My AI")
    }
}
