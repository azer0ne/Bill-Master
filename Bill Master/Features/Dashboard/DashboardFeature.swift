//
//  Dashboard.swift
//  BillMaster
//
//  Created by Reza on 21/04/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct DashboardFeature {
    enum DashboardError: Error, Equatable {
        case failed(String)
    }
    
    @ObservableState
    struct State: Equatable {
        var subscriptions: IdentifiedArrayOf<Subscription> = []
        var isLoading: Bool = false
        var errorMessage: String?
        @Presents var subscriptionDetail: SubscriptionDetailFeature.State?
        @Presents var subscriptionForm: SubscriptionFormFeature.State?

        var prioritySubscription: Subscription? {
            subscriptions.first
        }
        
        var remainingSubscriptions: IdentifiedArrayOf<Subscription> {
            IdentifiedArray(uniqueElements: subscriptions.dropFirst())
        }
        
        init(subscriptions: IdentifiedArrayOf<Subscription> = []) {
            self.subscriptions = subscriptions
        }
    }

    enum Action: Equatable {
        case onAppear
        case subscriptionsResponse(Result<[Subscription], DashboardError>)
        case subscriptionTapped(Subscription)
        case addSubscriptionTapped
        case subscriptionDetail(PresentationAction<SubscriptionDetailFeature.Action>)
        case subscriptionForm(PresentationAction<SubscriptionFormFeature.Action>)
    }
    
    @Dependency(\.databaseClient) var databaseClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        let subscriptions = try await databaseClient.fetchSubscriptions()
                        await send(.subscriptionsResponse(.success(subscriptions)))
                    } catch is CancellationError {
                    } catch {
                        await send(.subscriptionsResponse(.failure(.failed(error.localizedDescription))))
                    }
                }
                .cancellable(id: "DashboardFeature.fetchSubscriptions", cancelInFlight: true)
                
            case let .subscriptionsResponse(.success(subscriptions)):
                state.isLoading = false
                state.errorMessage = nil
                state.subscriptions = IdentifiedArray(
                    uniqueElements: subscriptions.sorted { lhs, rhs in
                        lhs.nextBillingDate < rhs.nextBillingDate
                    }
                )
                return .none
                
            case let .subscriptionsResponse(.failure(error)):
                state.isLoading = false
                state.subscriptions = []
                switch error {
                case let .failed(message):
                    state.errorMessage = message
                }
                return .none

            case let .subscriptionTapped(subscription):
                state.subscriptionDetail = SubscriptionDetailFeature.State(subscription: subscription)
                return .none
                
            case .addSubscriptionTapped:
                state.subscriptionForm = SubscriptionFormFeature.State()
                return .none
                
            case .subscriptionDetail(.presented(.delegate(.markedAsPaid))):
                state.subscriptionDetail = nil
                return .send(.onAppear)
                
            case let .subscriptionDetail(.presented(.delegate(.edit(subscription)))):
                state.subscriptionDetail = nil
                state.subscriptionForm = SubscriptionFormFeature.State(subscription: subscription)
                return .none
                
            case .subscriptionDetail:
                return .none
                
            case .subscriptionForm(.presented(.delegate(.cancel))):
                state.subscriptionForm = nil
                return .none
                
            case .subscriptionForm(.presented(.delegate(.saved))):
                state.subscriptionForm = nil
                return .send(.onAppear)
                
            case .subscriptionForm:
                return .none
            }
        }
        .ifLet(\.$subscriptionDetail, action: \.subscriptionDetail) {
            SubscriptionDetailFeature()
        }
        .ifLet(\.$subscriptionForm, action: \.subscriptionForm) {
            SubscriptionFormFeature()
        }
    }
}
