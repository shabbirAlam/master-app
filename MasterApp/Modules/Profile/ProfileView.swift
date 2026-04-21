//
//  ProfileView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var router: Router

    var body: some View {
        VStack {
            Button {
                router.push(.profile(type: .editProfile))
            } label: {
                Text("Edit profile")
            }
        }
    }
}
