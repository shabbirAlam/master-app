import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var router: Router
    @Environment(\.appContainer) private var container

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack(path: $router.path) {
            TabView(selection: $selectedTab) {
                HomeView(viewModel: HomeViewModel(features: HomeFeatures.allCases))
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
            .navigationDestination(for: AppRoute.self) { route in
                route.destination(container: container)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(Router())
        .environment(\.appContainer, AppDIContainer())
}
