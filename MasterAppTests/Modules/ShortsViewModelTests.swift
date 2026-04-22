//
//  ShortsViewModelTests.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Testing
@testable import MasterApp

struct ShortsViewModelTests {
    @Test
    func validate() {
        let vm = ShortsViewModel()
        #expect(vm.title == "Shorts")
        #expect(vm.urls.isEmpty == false)
        #expect(vm.urls.count == 10)
        vm.getNextVideos()
        #expect(vm.urls.count == 20)
    }
}
