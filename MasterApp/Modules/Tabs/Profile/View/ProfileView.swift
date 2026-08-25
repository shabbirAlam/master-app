import SwiftUI

/// Profile tab root screen with a button to open profile editing.
struct ProfileView: View {
    /// The app-wide navigation stack.
    @Environment(Router.self) private var router

    /// Renders the edit-profile entry point.
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
