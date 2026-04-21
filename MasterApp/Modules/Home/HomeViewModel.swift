//
//  HomeViewModel.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Combine
import SwiftUI

final class HomeViewModel: ObservableObject {
    var items = ["Todo", "new"]
    
    func route(for index: Int) -> AppRoute? {
        switch index {
            case 0:
                return .home(type: .todo)
            default:
                return nil
        }
    }
}
