//
//  ProfileDetailsView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI

struct ProfileDetailsView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            Button {
                router.pop()
            } label: {
                Text("Back")
                    .padding()
            }
            
            Button {
                router.popToRoot()
            } label: {
                Text("Back to root")
                    .padding()
            }
        }
        .navigationTitle("Profile details")
    }
}
