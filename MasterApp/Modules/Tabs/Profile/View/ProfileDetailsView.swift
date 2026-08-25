import SwiftUI

/// Profile editing screen demonstrating navigation pop actions.
struct ProfileDetailsView: View {
    /// The app-wide navigation stack.
    @Environment(Router.self) private var router

    /// Renders back-navigation controls.
    var body: some View {
        VStack(spacing: 16) {
            Button {
                router.pop()
            } label: {
                Text("Back")
                    .padding()
            }
            .accessibilityIdentifier("back_button")
            .accessibilityLabel("Back")

            Button {
                router.popToRoot()
            } label: {
                Text("Back to root")
                    .padding()
            }
            .accessibilityIdentifier("back_to_root")
            .accessibilityLabel("Back to root")
        }
        .navigationTitle("Profile details")
    }
}
