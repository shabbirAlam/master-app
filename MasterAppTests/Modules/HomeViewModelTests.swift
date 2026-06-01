import Testing
@testable import MasterApp

@MainActor
struct HomeViewModelTests {
    @Test
    func itemsContainExpectedFeatures() {
        let vm = HomeViewModel()
        #expect(vm.items.isEmpty == false)
        #expect(vm.items.contains(.restAPISearch))
        #expect(vm.items.contains(.graphQLSearch))
        #expect(vm.items.contains(.secureView))
        
        #expect(vm.route(for: .restAPISearch) == .home(type: .restAPISearch))
        #expect(vm.route(for: .graphQLSearch) == .home(type: .graphQLSearch))
        #expect(vm.route(for: .secureView) == .home(type: .secureView))
    }
    
    @Test
    func featureCountIsThree() {
        let vm = HomeViewModel()
        #expect(vm.items.count == 3)
        #expect(vm.items.contains(.restAPISearch))
        #expect(vm.items.contains(.graphQLSearch))
        #expect(vm.items.contains(.secureView))
    }
}
