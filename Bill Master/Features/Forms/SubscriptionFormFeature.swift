//
//  SubscriptionFormFeature.swift
//  BillMaster
//
//  Created by Reza on 13/05/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SubscriptionFormFeature {
    enum Mode: Equatable {
        case add
        case edit(UUID)
    }
    
    enum FormError: Error, Equatable {
        case failed(String)
    }
    
    enum ValidationError: Equatable {
        case nameRequired
        case amountRequired
        case dueDateInvalid
        
        var message: String {
            switch self {
            case .nameRequired:
                return "Service name is required."
            case .amountRequired:
                return "Amount must be greater than 0."
            case .dueDateInvalid:
                return "Due date is invalid."
            }
        }
    }
    
    @ObservableState
    struct State: Equatable {
        var mode: Mode
        var name: String
        var amountText: String
        var dueDate: Date
        var billingFrequency: BillingFrequency
        var paymentMethods: IdentifiedArrayOf<PaymentMethod> = []
        var selectedPaymentMethodID: PaymentMethod.ID?
        var autoRenew: Bool
        var selectedCategory: SubscriptionCategory?
        var isLoadingPaymentMethods = false
        var isSaving = false
        var validationError: ValidationError?
        var errorMessage: String?
        
        var title: String {
            switch mode {
            case .add:
                return "Add Subscription"
            case .edit:
                return "Edit Subscription"
            }
        }
        
        var saveButtonTitle: String {
            switch mode {
            case .add:
                return "Add Bill"
            case .edit:
                return "Save Changes"
            }
        }
        
        var amount: Double? {
            Double(Self.digitsOnly(from: amountText))
        }
        
        init(mode: Mode = .add) {
            self.mode = mode
            self.name = ""
            self.amountText = ""
            self.dueDate = Date()
            self.billingFrequency = .monthly
            self.autoRenew = true
            self.selectedCategory = nil
        }
        
        init(subscription: Subscription) {
            self.mode = .edit(subscription.id)
            self.name = subscription.name
            self.amountText = Self.amountString(from: subscription.amount)
            self.dueDate = subscription.nextBillingDate
            self.billingFrequency = subscription.frequency
            self.paymentMethods = IdentifiedArray(uniqueElements: subscription.paymentMethod.map { [$0] } ?? [])
            self.selectedPaymentMethodID = subscription.paymentMethod?.id
            self.autoRenew = subscription.autoRenew
            self.selectedCategory = subscription.category
        }
        
        private static func amountString(from amount: Double) -> String {
            formattedAmountText(from: String(Int(amount.rounded())))
        }

        static func formattedAmountText(from text: String) -> String {
            let digits = digitsOnly(from: text)
            guard !digits.isEmpty else { return "" }

            let reversedDigits = digits.reversed()
            let groups = stride(from: 0, to: reversedDigits.count, by: 3).map { startIndex in
                let start = reversedDigits.index(reversedDigits.startIndex, offsetBy: startIndex)
                let end = reversedDigits.index(start, offsetBy: 3, limitedBy: reversedDigits.endIndex) ?? reversedDigits.endIndex
                return String(reversedDigits[start..<end].reversed())
            }

            return groups.reversed().joined(separator: ".")
        }

        private static func digitsOnly(from text: String) -> String {
            text.filter(\.isNumber)
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case amountTextChanged(String)
        case onAppear
        case paymentMethodsResponse(Result<[PaymentMethod], FormError>)
        case cancelTapped
        case saveTapped
        case saveSucceeded
        case saveFailed(FormError)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case cancel
            case saved
        }
    }
    
    @Dependency(\.calendar) var calendar
    @Dependency(\.databaseClient) var databaseClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case let .amountTextChanged(text):
                state.amountText = State.formattedAmountText(from: text)
                state.validationError = nil
                state.errorMessage = nil
                return .none

            case .binding:
                state.validationError = nil
                state.errorMessage = nil
                return .none
                
            case .onAppear:
                state.isLoadingPaymentMethods = true
                return .run { send in
                    do {
                        let paymentMethods = try await databaseClient.fetchPaymentMethods()
                        await send(.paymentMethodsResponse(.success(paymentMethods)))
                    } catch is CancellationError {
                    } catch {
                        await send(.paymentMethodsResponse(.failure(.failed(error.localizedDescription))))
                    }
                }
                .cancellable(id: "SubscriptionFormFeature.fetchPaymentMethods", cancelInFlight: true)
                
            case let .paymentMethodsResponse(.success(paymentMethods)):
                state.isLoadingPaymentMethods = false
                let existingSelectedID = state.selectedPaymentMethodID
                let mergedPaymentMethods = merge(state.paymentMethods.elements, with: paymentMethods)
                state.paymentMethods = IdentifiedArray(uniqueElements: mergedPaymentMethods)
                
                if let existingSelectedID, state.paymentMethods[id: existingSelectedID] != nil {
                    state.selectedPaymentMethodID = existingSelectedID
                } else {
                    state.selectedPaymentMethodID = state.paymentMethods.first?.id
                }
                return .none
                
            case let .paymentMethodsResponse(.failure(error)):
                state.isLoadingPaymentMethods = false
                switch error {
                case let .failed(message):
                    state.errorMessage = message
                }
                return .none
                
            case .cancelTapped:
                return .send(.delegate(.cancel))
                
            case .saveTapped:
                guard validate(&state) else {
                    return .none
                }
                
                let subscription = makeSubscription(from: state)
                state.isSaving = true
                state.errorMessage = nil
                
                return .run { [mode = state.mode] send in
                    do {
                        switch mode {
                        case .add:
                            try await databaseClient.createSubscription(subscription)
                        case .edit:
                            try await databaseClient.updateSubscription(subscription)
                        }
                        
                        await send(.saveSucceeded)
                    } catch is CancellationError {
                    } catch {
                        await send(.saveFailed(.failed(error.localizedDescription)))
                    }
                }
                
            case .saveSucceeded:
                state.isSaving = false
                return .send(.delegate(.saved))
                
            case let .saveFailed(error):
                state.isSaving = false
                switch error {
                case let .failed(message):
                    state.errorMessage = message
                }
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
    
    private func validate(_ state: inout State) -> Bool {
        let trimmedName = state.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            state.validationError = .nameRequired
            return false
        }
        
        guard let amount = state.amount, amount > 0 else {
            state.validationError = .amountRequired
            return false
        }
        
        guard calendar.dateComponents([.year], from: state.dueDate).year != nil else {
            state.validationError = .dueDateInvalid
            return false
        }
        
        return true
    }
    
    private func makeSubscription(from state: State) -> Subscription {
        let id: UUID
        switch state.mode {
        case .add:
            id = UUID()
        case let .edit(subscriptionID):
            id = subscriptionID
        }
        
        return Subscription(
            id: id,
            name: state.name.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: state.amount ?? 0,
            frequency: state.billingFrequency,
            category: state.selectedCategory ?? .other,
            nextBillingDate: state.dueDate,
            paymentMethod: state.selectedPaymentMethodID.flatMap { state.paymentMethods[id: $0] },
            autoRenew: state.autoRenew
        )
    }
    
    private func merge(_ current: [PaymentMethod], with fetched: [PaymentMethod]) -> [PaymentMethod] {
        var result = current
        for paymentMethod in fetched where !result.contains(where: { $0.id == paymentMethod.id }) {
            result.append(paymentMethod)
        }
        return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
