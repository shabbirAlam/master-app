//
//  EnvironmentKeys.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 03/06/26.
//

import SwiftUI

private struct AppContainerKey: EnvironmentKey {
    @MainActor static var defaultValue: AppDIContainer = AppDIContainer()
}

extension EnvironmentValues {
    var appContainer: AppDIContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
