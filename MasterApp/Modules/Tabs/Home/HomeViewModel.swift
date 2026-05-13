//
//  HomeViewModel.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Combine

final class HomeViewModel {
    private(set) var items: [HomeFeatures] = []
    
    init() {
        setRows()
    }
    
    func setRows() {
        self.items = [.restAPISearch, .graphQLSearch]
        if AIAvailability.isEnabled() {
            self.items.insert(.ai, at: 0)
        }
    }
    
    func route(for item: HomeFeatures) -> AppRoute? {
        return switch item {
        case .ai: .home(type: .ai)
        case .graphQLSearch: .home(type: .graphQLSearch)
        case .restAPISearch: .home(type: .restAPISearch)
        }
    }
}
