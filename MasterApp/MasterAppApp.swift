import SwiftUI

/// The app entry point. Creates the dependency container and injects it
/// into the environment for all downstream views.
@main
struct MasterAppApp: App {
    /// The shared dependency container owned by the app.
    @State private var container = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(container)
        }
    }
}
