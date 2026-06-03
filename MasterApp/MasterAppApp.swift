import SwiftUI

@main
struct MasterAppApp: App {
    @State private var container = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(container)
        }
    }
}
