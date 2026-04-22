//
//  HomeViewModel.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Combine

final class HomeViewModel: ObservableObject {
    var items = [HomeFeatures.todo]
    
    func route(for item: HomeFeatures) -> AppRoute? {
        switch item {
            case .todo:
                return .home(type: .todo)
        }
    }
}
