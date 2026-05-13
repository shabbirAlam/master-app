//
//  SecureView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 13/05/26.
//

import SwiftUI

enum SecureBuilder {
    static func build() -> SecureView {
        SecureView()
    }
}

struct SecureView: View {
    var body: some View {
        Text("This is secure view")
            .secure()
    }
}

#Preview {
    SecureView()
}
