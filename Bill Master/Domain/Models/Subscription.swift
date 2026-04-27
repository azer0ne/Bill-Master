//
//  Subscription.swift
//  BillMaster
//
//  Created by Reza on 22/04/26.
//

import Foundation

public struct Subscription: Equatable, Identifiable {
    public let id: UUID
    public var name: String
    public var amount: Double
    public var currency: Currency
    public var frequency: BillingFrequency
    public var category: SubscriptionCategory
    public var nextBillingDate: Date // Use an absolute date instead of an Int for the day
    public var paymentMethod: PaymentMethod? // Optional payment method relation
    
    public init(
        id: UUID = UUID(), 
        name: String, 
        amount: Double, 
        currency: Currency = .IDR, 
        frequency: BillingFrequency = .monthly,
        category: SubscriptionCategory,
        nextBillingDate: Date,
        paymentMethod: PaymentMethod? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.currency = currency
        self.frequency = frequency
        self.category = category
        self.nextBillingDate = nextBillingDate
        self.paymentMethod = paymentMethod
    }
}

public enum Currency: String, Codable {
    case IDR, USD, SGD, EUR, GBP
}

public enum BillingFrequency: String, Codable {
    case monthly, quarterly, yearly
}

public enum SubscriptionCategory: String, Codable {
    case entertainment, utility, software, other
}
