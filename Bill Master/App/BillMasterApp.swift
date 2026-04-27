//
//  BillMasterApp.swift
//  BillMaster
//
//  Created by Reza on 21/04/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct BillMasterApp: App {
    static let store = Store(initialState: AppRootFeature.State()) {
        AppRootFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView(store: BillMasterApp.store)
        }
    }
}
