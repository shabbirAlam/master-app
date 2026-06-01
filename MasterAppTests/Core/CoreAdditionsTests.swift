import Testing
import SwiftUI
@testable import MasterApp

@MainActor
struct AppDIContainerTests {
    @Test func defaultInstance() {
        let container = AppDIContainer()
        #expect(container.networking is NetworkingImpl)
    }
}

@MainActor
struct ThemeManagerTests {
    @Test func sharedInstance() {
        let theme = ThemeManager.shared
        #expect(theme.background == .white)
        #expect(theme.textPrimary == .black)
    }
}

@MainActor
struct AppRouteEqualityTests {
    @Test func appRouteEquality() {
        #expect(AppRoute.home(type: .secureView) == AppRoute.home(type: .secureView))
        #expect(AppRoute.home(type: .secureView) != AppRoute.home(type: .graphQLSearch))
        #expect(AppRoute.profile(type: .editProfile) == AppRoute.profile(type: .editProfile))
    }

    @Test func appRouteHashable() {
        let routes: Set<AppRoute> = [
            .home(type: .secureView),
            .home(type: .graphQLSearch),
            .home(type: .restAPISearch),
            .profile(type: .editProfile)
        ]
        #expect(routes.count == 4)
    }
}

@MainActor
struct AppRouteImplTests {
    @Test func homeRouteDestinations() {
        _ = AppRoute.home(type: .secureView).destination()
        _ = AppRoute.home(type: .graphQLSearch).destination()
        _ = AppRoute.home(type: .restAPISearch).destination()
    }

    @Test func profileRouteDestination() {
        _ = AppRoute.profile(type: .editProfile).destination()
    }
}

@MainActor
struct APIEndpointTodosTests {
    @Test func todosEndpointConfiguration() {
        let endpoint = APIEndpoint.todos
        #expect(endpoint.baseURL == ApiConfig.todoBaseURL)
        #expect(endpoint.path == "posts")
        #expect(endpoint.method == .GET)
    }
}

@MainActor
struct PreviewNetworkingMockErrorPathTests {
    @Test func requestError() async {
        let mock = PreviewNetworkingMock()
        mock.setError(NetworkError.unknown)
        let endpoint = APIEndpoint(baseURL: "https://example.com", path: "todos")
        await #expect(throws: NetworkError.unknown) {
            let _: Todo = try await mock.request(endpoint)
        }
    }
}

@MainActor
struct RouterDuplicateRouteTests {
    @Test func popToWithDuplicateAtEnd() {
        let router = Router()
        router.push(.home(type: .restAPISearch))
        router.push(.profile(type: .editProfile))
        router.push(.home(type: .restAPISearch))

        router.popTo(.home(type: .restAPISearch))
        // lastIndex is 2, elementsToRemove = 3 - 3 = 0 → no change
        #expect(router.path.count == 3)
    }

    @Test func popToWithDuplicateInMiddle() {
        let router = Router()
        router.push(.home(type: .restAPISearch))
        router.push(.home(type: .secureView))
        router.push(.home(type: .restAPISearch))
        router.push(.home(type: .graphQLSearch))

        router.popTo(.home(type: .restAPISearch))
        // lastIndex is 2, elementsToRemove = 4 - 3 = 1 → removes graphQLSearch
        #expect(router.path.count == 3)
        #expect(router.path[0] == .home(type: .restAPISearch))
        #expect(router.path[1] == .home(type: .secureView))
        #expect(router.path[2] == .home(type: .restAPISearch))
    }
}
