import SwiftUI

struct ProfileView: View {
    @Environment(Router.self) private var router

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
