//
//  AppDIContainer.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 30/04/26.
//

import Combine

struct AppDIContainer {
    static let shared: AppDIContainer = AppDIContainer()
    let networking: Networking
    
    private init() {
        self.networking = NetworkingImpl()
    }
}
