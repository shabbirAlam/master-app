import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack {
            Button {
                router.push(.profile(type: .editProfile))
            } label: {
                Text("Edit profile")
            }
            .accessibilityIdentifier("edit_profile")
            .accessibilityLabel("Edit profile")
        }
    }
}
