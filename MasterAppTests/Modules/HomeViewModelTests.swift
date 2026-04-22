//
//  HomeViewModelTests.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Testing
@testable import MasterApp

struct HomeViewModelTests {
    @Test
    func itemsValidation() async throws {
        let vm = HomeViewModel()
        #expect(vm.items.isEmpty == false)
        #expect(vm.items.count == 1)
        #expect(vm.items[0] == .todo)
        await #expect(vm.items[0].name == "Todo")
        
        #expect(vm.route(for: .todo) == .home(type: .todo))
    }
}
