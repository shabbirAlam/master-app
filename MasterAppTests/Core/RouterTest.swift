//
//  RouterTest.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Testing
@testable import MasterApp

@MainActor
struct RouterTest {
    @Test
    func routerPush() {
        let router = Router()
        
        #expect(router.path.isEmpty)
        
        router.push(.home(type: .restAPISearch))
        #expect(router.path.count == 1)
        #expect(router.path[0] == .home(type: .restAPISearch))
        
        router.push(.profile(type: .editProfile))
        #expect(router.path.count == 2)
        #expect(router.path[0] == .home(type: .restAPISearch))
        #expect(router.path[1] == .profile(type: .editProfile))
    }
    
    @Test
    func routerPop() {
        let router = Router()
        
        router.push(.home(type: .restAPISearch))
        #expect(router.path.count == 1)
        
        router.pop()
        #expect(router.path.isEmpty)
        router.pop()
        #expect(router.path.isEmpty)
        
        router.push(.home(type: .restAPISearch))
        router.push(.profile(type: .editProfile))
        #expect(router.path.count == 2)
        #expect(router.path[0] == .home(type: .restAPISearch))
        #expect(router.path[1] == .profile(type: .editProfile))
        
        router.popToRoot()
        #expect(router.path.isEmpty)
        router.popToRoot()
        #expect(router.path.isEmpty)
    }
    
    @Test
    func routerPopTo() {
        let router = Router()
        
        router.push(.home(type: .restAPISearch))
        router.push(.profile(type: .editProfile))
        #expect(router.path.count == 2)
        #expect(router.path[0] == .home(type: .restAPISearch))
        #expect(router.path[1] == .profile(type: .editProfile))
        
        router.popTo(.home(type: .restAPISearch))
        #expect(router.path.count == 1)
        #expect(router.path[0] == .home(type: .restAPISearch))
        
        router.popTo(.home(type: .restAPISearch))
        #expect(router.path.count == 1)
        #expect(router.path[0] == .home(type: .restAPISearch))
        
        router.pop()
        #expect(router.path.isEmpty)
        
        router.popTo(.home(type: .restAPISearch))
        #expect(router.path.isEmpty)
    }
    
    @Test
    func popToRootWhenAlreadyEmpty() {
        let router = Router()
        #expect(router.path.isEmpty)
        router.popToRoot()
        #expect(router.path.isEmpty)
    }
    
    @Test
    func popToNonExistentRoute() {
        let router = Router()
        router.push(.home(type: .restAPISearch))
        router.popTo(.profile(type: .editProfile))
        #expect(router.path.count == 1)
    }
}
