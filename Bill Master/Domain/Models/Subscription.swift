//
//  Subscription.swift
//  BillMaster
//
//  Created by Reza on 22/04/26.
//

import Foundation

nonisolated public struct Subscription: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var amount: Double
    public var currency: Currency
    public var frequency: BillingFrequency
    public var category: SubscriptionCategory
    public var nextBillingDate: Date
    public var paymentMethod: PaymentMethod?
    public var autoRenew: Bool
    
    public init(
        id: UUID = UUID(), 
        name: String, 
        amount: Double, 
        currency: Currency = .idr,
        frequency: BillingFrequency = .monthly,
        category: SubscriptionCategory,
        nextBillingDate: Date,
        paymentMethod: PaymentMethod? = nil,
        autoRenew: Bool = true
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.currency = currency
        self.frequency = frequency
        self.category = category
        self.nextBillingDate = nextBillingDate
        self.paymentMethod = paymentMethod
        self.autoRenew = autoRenew
    }
}

nonisolated public enum Currency: String, Codable, Sendable, CaseIterable {
    case idr = "IDR"
    case usd = "USD"
    case sgd = "SGD"
    case eur = "EUR"
    case gbp = "GBP"
}

nonisolated public enum BillingFrequency: String, Codable, Sendable, CaseIterable {
    case weekly, monthly, quarterly, yearly
}

nonisolated public enum SubscriptionCategory: String, Codable, Sendable, CaseIterable {
    case entertainment, utility, software, other
}
