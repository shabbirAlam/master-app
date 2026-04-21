//
//  Router.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Combine

final class Router: ObservableObject {
    @Published var path: [AppRoute] = []
    
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeAll()
    }
    
    func popTo(_ route: AppRoute) {
        guard let index = path.lastIndex(of: route) else {
            return // route not found → do nothing
        }
        
        let elementsToRemove = path.count - (index + 1)
        
        guard elementsToRemove > 0 else { return }
        
        path.removeLast(elementsToRemove)
    }
}
