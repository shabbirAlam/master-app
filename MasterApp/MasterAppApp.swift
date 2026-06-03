import SwiftUI

@main
struct MasterAppApp: App {
    @StateObject private var router = Router()
    @State private var container = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(router)
                .environment(\.appContainer, container)
        }
    }
}
