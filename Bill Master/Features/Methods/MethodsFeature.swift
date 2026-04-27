//
//  MethodsFeature.swift
//  BillMaster
//
//  Created by Reza on 21/04/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MethodsFeature {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        case onAppear
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
