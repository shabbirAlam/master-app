import SwiftUI

struct DashboardView: View {
    @Environment(AppDIContainer.self) private var container
    @State private var router = Router()

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack(path: $router.path) {
            TabView(selection: $selectedTab) {
                HomeBuilder.build(container: container)
                    .secure()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(1)
            }
            .tint(container.theme.accent)
            .navigationDestination(for: AppRoute.self) { route in
                route.destination(container: container)
            }
        }
        .environment(router)
        .onAppear {
            styleTabBar(with: container.theme)
        }
    }

    private func styleTabBar(with theme: Theme) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(theme.background)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(theme.textPrimary).withAlphaComponent(0.5)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(theme.accent)
        ]

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(theme.textPrimary).withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(theme.accent)

        // Sets global tab bar appearance via UIKit proxy. This is a known
        // limitation — if multiple views customize the tab bar, the last
        // call wins. For this app's single-tab-bar architecture it's safe.
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    let container = AppDIContainer()
    DashboardView()
        .environment(container)
}
