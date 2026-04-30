//
//  AppDIContainer.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 30/04/26.
//

import Combine

final class AppDIContainer: ObservableObject {
    let networking: Networking
    
    init(networking: Networking = NetworkingImpl()) {
        self.networking = networking
    }
}
