//
//  AppRootView.swift
//  BillMaster
//
//  Created by Reza on 21/04/26.
//

import SwiftUI
import ComposableArchitecture

struct AppRootView: View {
    @Bindable var store: StoreOf<AppRootFeature>
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            DashboardView(
                store: store.scope(state: \.dashboard, action: \.dashboard)
            )
            .tabItem {
                Label("Dashboard", systemImage: "sparkles")
            }
            .tag(AppRootFeature.Tab.dashboard)
            
            MethodsView(
                store: store.scope(state: \.methods, action: \.methods)
            )
            .tabItem {
                Label("Methods", systemImage: "wallet.pass")
            }
            .tag(AppRootFeature.Tab.methods)
            
            AccountView(
                store: store.scope(state: \.account, action: \.account)
            )
            .tabItem {
                Label("Account", systemImage: "person")
            }
            .tag(AppRootFeature.Tab.account)
        }
        .tint(.blue)
    }
}
