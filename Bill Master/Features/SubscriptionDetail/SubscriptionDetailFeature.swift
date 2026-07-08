//
//  SubscriptionDetailFeature.swift
//  BillMaster
//
//  Created by Reza on 18/05/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SubscriptionDetailFeature {
    enum DetailError: Error, Equatable {
        case failed(String)
    }
    
    @ObservableState
    struct State: Equatable {
        var subscription: Subscription
        var isMarkingAsPaid = false
        var errorMessage: String?
        
        init(subscription: Subscription) {
            self.subscription = subscription
        }
    }
    
    enum Action: Equatable {
        case markAsPaidTapped
        case markAsPaidResponse(Result<Subscription, DetailError>)
        case editTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case markedAsPaid
            case edit(Subscription)
        }
    }
    
    @Dependency(\.calendar) var calendar
    @Dependency(\.databaseClient) var databaseClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .markAsPaidTapped:
                guard let updatedSubscription = advancedSubscription(state.subscription, calendar: calendar) else {
                    state.errorMessage = "Unable to advance the next billing date."
                    return .none
                }
                
                state.isMarkingAsPaid = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        try await databaseClient.updateSubscription(updatedSubscription)
                        await send(.markAsPaidResponse(.success(updatedSubscription)))
                    } catch is CancellationError {
                    } catch {
                        await send(.markAsPaidResponse(.failure(.failed(error.localizedDescription))))
                    }
                }
                
            case let .markAsPaidResponse(.success(subscription)):
                state.isMarkingAsPaid = false
                state.subscription = subscription
                return .send(.delegate(.markedAsPaid))
                
            case let .markAsPaidResponse(.failure(error)):
                state.isMarkingAsPaid = false
                switch error {
                case let .failed(message):
                    state.errorMessage = message
                }
                return .none
                
            case .editTapped:
                return .send(.delegate(.edit(state.subscription)))
                
            case .delegate:
                return .none
            }
        }
    }
    
    private func advancedSubscription(_ subscription: Subscription, calendar: Calendar) -> Subscription? {
        var updatedSubscription = subscription
        let component: Calendar.Component
        let value: Int
        
        switch subscription.frequency {
        case .weekly:
            component = .day
            value = 7
        case .monthly:
            component = .month
            value = 1
        case .quarterly:
            component = .month
            value = 3
        case .yearly:
            component = .year
            value = 1
        }
        
        guard let nextBillingDate = calendar.date(
            byAdding: component,
            value: value,
            to: subscription.nextBillingDate
        ) else {
            return nil
        }
        
        updatedSubscription.nextBillingDate = nextBillingDate
        return updatedSubscription
    }
}
