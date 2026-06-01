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

private struct AppContainerKey: EnvironmentKey {
    @MainActor static var defaultValue: AppDIContainer = AppDIContainer()
}

extension EnvironmentValues {
    var appContainer: AppDIContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
