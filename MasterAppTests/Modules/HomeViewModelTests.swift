import Testing
@testable import MasterApp

@MainActor
struct HomeViewModelTests {
    @Test
    func itemsContainExpectedFeatures() {
        let vm = HomeViewModel(features: HomeFeatures.allCases, theme: AppTheme.light)
        #expect(vm.items.isEmpty == false)
        #expect(vm.items.contains(.restAPISearch))
        #expect(vm.items.contains(.graphQLSearch))
        #expect(vm.items.contains(.secureView))
        #expect(vm.items.contains(.chess))

        #expect(vm.route(for: .restAPISearch) == .home(type: .restAPISearch))
        #expect(vm.route(for: .graphQLSearch) == .home(type: .graphQLSearch))
        #expect(vm.route(for: .secureView) == .home(type: .secureView))
        #expect(vm.route(for: .chess) == .home(type: .chess))
    }

    @Test
    func featureCountIsFour() {
        let vm = HomeViewModel(features: HomeFeatures.allCases, theme: AppTheme.light)
        #expect(vm.items.count == 4)
        #expect(vm.items.contains(.restAPISearch))
        #expect(vm.items.contains(.graphQLSearch))
        #expect(vm.items.contains(.secureView))
        #expect(vm.items.contains(.chess))
    }
}
