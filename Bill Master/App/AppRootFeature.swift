//
//  AppRootFeature.swift
//  BillMaster
//
//  Created by Reza on 27/04/26.
//

import ComposableArchitecture

@Reducer
struct AppRootFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .dashboard
        
        // Child feature states
        var dashboard = DashboardFeature.State()
        var methods = MethodsFeature.State()
        var account = AccountFeature.State()
    }
    
    enum Tab: String, Equatable {
        case dashboard
        case methods
        case account
    }
    
    enum Action {
        case tabSelected(Tab)
        
        // Child feature actions
        case dashboard(DashboardFeature.Action)
        case methods(MethodsFeature.Action)
        case account(AccountFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.dashboard, action: \.dashboard) {
            DashboardFeature()
        }
        Scope(state: \.methods, action: \.methods) {
            MethodsFeature()
        }
        Scope(state: \.account, action: \.account) {
            AccountFeature()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            // Ignore child actions at the root level unless cross-feature communication is needed
            case .dashboard, .methods, .account:
                return .none
            }
        }
    }
}
