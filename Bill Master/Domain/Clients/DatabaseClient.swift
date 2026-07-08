//
//  DatabaseClient.swift
//  BillMaster
//
//  Created by Reza on 21/04/26.
//

import Foundation
import CoreData
import ComposableArchitecture

public struct DatabaseClient {
    public var fetchSubscriptions: @Sendable () async throws -> [Subscription]
    public var fetchPaymentMethods: @Sendable () async throws -> [PaymentMethod]
    public var createSubscription: @Sendable (Subscription) async throws -> Void
    public var updateSubscription: @Sendable (Subscription) async throws -> Void
    public var saveSubscription: @Sendable (Subscription) async throws -> Void
}

extension DatabaseClient {
    public static var live: DatabaseClient {
        let container = NSPersistentContainer(name: "BillMaster")
        container.persistentStoreDescriptions.forEach { description in
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load CoreData stack: \(error.localizedDescription)")
            }
        }
        
        return DatabaseClient(
            fetchSubscriptions: {
                let context = container.newBackgroundContext()
                return try await context.perform {
                    let request = NSFetchRequest<NSManagedObject>(entityName: "CDSubscription")
                    let results = try context.fetch(request)
                    
                    return results.compactMap { cdSubscription in
                        guard
                            let id = cdSubscription.value(forKey: "id") as? UUID,
                            let name = cdSubscription.value(forKey: "name") as? String,
                            let amount = cdSubscription.value(forKey: "amount") as? Double,
                            let currencyString = cdSubscription.value(forKey: "currency") as? String,
                            let currency = Currency(rawValue: currencyString),
                            let frequencyString = cdSubscription.value(forKey: "frequencyValue") as? String,
                            let frequency = BillingFrequency(rawValue: frequencyString),
                            let categoryString = cdSubscription.value(forKey: "categoryValue") as? String,
                            let category = SubscriptionCategory(rawValue: categoryString),
                            let nextBillingDate = cdSubscription.value(forKey: "nextBillingDate") as? Date
                        else { return nil }
                        
                        return Subscription(
                            id: id,
                            name: name,
                            amount: amount,
                            currency: currency,
                            frequency: frequency,
                            category: category,
                            nextBillingDate: nextBillingDate,
                            paymentMethod: Self.makePaymentMethod(from: cdSubscription.value(forKey: "paymentMethod") as? NSManagedObject),
                            autoRenew: cdSubscription.value(forKey: "autoRenew") as? Bool ?? true
                        )
                    }
                }
            },
            fetchPaymentMethods: {
                let context = container.newBackgroundContext()
                return try await context.perform {
                    let request = NSFetchRequest<NSManagedObject>(entityName: "CDPaymentMethod")
                    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                    return try context.fetch(request).compactMap(Self.makePaymentMethod(from:))
                }
            },
            createSubscription: { subscription in
                let context = container.newBackgroundContext()
                try await context.perform {
                    let cdSub = NSEntityDescription.insertNewObject(forEntityName: "CDSubscription", into: context)
                    try Self.update(cdSub, with: subscription, in: context)
                    if context.hasChanges {
                        try context.save()
                    }
                }
            },
            updateSubscription: { subscription in
                let context = container.newBackgroundContext()
                try await context.perform {
                    let request = NSFetchRequest<NSManagedObject>(entityName: "CDSubscription")
                    request.predicate = NSPredicate(format: "id == %@", subscription.id as CVarArg)
                    
                    let cdSub = try context.fetch(request).first
                        ?? NSEntityDescription.insertNewObject(forEntityName: "CDSubscription", into: context)
                    try Self.update(cdSub, with: subscription, in: context)
                    if context.hasChanges {
                        try context.save()
                    }
                }
            },
            saveSubscription: { subscription in
                let context = container.newBackgroundContext()
                try await context.perform {
                    let request = NSFetchRequest<NSManagedObject>(entityName: "CDSubscription")
                    request.predicate = NSPredicate(format: "id == %@", subscription.id as CVarArg)
                    
                    let cdSub = try context.fetch(request).first
                        ?? NSEntityDescription.insertNewObject(forEntityName: "CDSubscription", into: context)
                    try Self.update(cdSub, with: subscription, in: context)
                    if context.hasChanges {
                        try context.save()
                    }
                }
            }
        )
    }
}

private extension DatabaseClient {
    nonisolated static func makePaymentMethod(from managedObject: NSManagedObject?) -> PaymentMethod? {
        guard
            let managedObject,
            let id = managedObject.value(forKey: "id") as? UUID,
            let name = managedObject.value(forKey: "name") as? String,
            let typeString = managedObject.value(forKey: "type") as? String,
            let type = PaymentType(rawValue: typeString)
        else { return nil }
        
        return PaymentMethod(id: id, name: name, type: type)
    }
    
    nonisolated static func update(_ managedObject: NSManagedObject, with subscription: Subscription, in context: NSManagedObjectContext) throws {
        managedObject.setValue(subscription.id, forKey: "id")
        managedObject.setValue(subscription.name, forKey: "name")
        managedObject.setValue(subscription.amount, forKey: "amount")
        managedObject.setValue(subscription.currency.rawValue, forKey: "currency")
        managedObject.setValue(subscription.frequency.rawValue, forKey: "frequencyValue")
        managedObject.setValue(subscription.category.rawValue, forKey: "categoryValue")
        managedObject.setValue(subscription.nextBillingDate, forKey: "nextBillingDate")
        managedObject.setValue(subscription.autoRenew, forKey: "autoRenew")
        
        guard let paymentMethod = subscription.paymentMethod else {
            managedObject.setValue(nil, forKey: "paymentMethod")
            return
        }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDPaymentMethod")
        request.predicate = NSPredicate(format: "id == %@", paymentMethod.id as CVarArg)
        
        let cdPaymentMethod = try context.fetch(request).first
            ?? NSEntityDescription.insertNewObject(forEntityName: "CDPaymentMethod", into: context)
        cdPaymentMethod.setValue(paymentMethod.id, forKey: "id")
        cdPaymentMethod.setValue(paymentMethod.name, forKey: "name")
        cdPaymentMethod.setValue(paymentMethod.type.rawValue, forKey: "type")
        managedObject.setValue(cdPaymentMethod, forKey: "paymentMethod")
    }
}

extension DatabaseClient: DependencyKey {
    public static let liveValue = DatabaseClient.live
    
    public static let testValue = DatabaseClient(
        fetchSubscriptions: { [] },
        fetchPaymentMethods: { [] },
        createSubscription: { _ in },
        updateSubscription: { _ in },
        saveSubscription: { _ in }
    )
    
    public static let previewValue = DatabaseClient(
        fetchSubscriptions: {
            [
                Subscription(
                    name: "Gemini Advanced",
                    amount: 309_000,
                    category: .software,
                    nextBillingDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
                ),
                Subscription(
                    name: "Spotify Family",
                    amount: 17_500,
                    category: .entertainment,
                    nextBillingDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()
                ),
                Subscription(
                    name: "Apple iCloud+",
                    amount: 15_000,
                    category: .utility,
                    nextBillingDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date()
                )
            ]
        },
        fetchPaymentMethods: {
            [
                PaymentMethod(name: "BCA Credit Card", type: .creditCard),
                PaymentMethod(name: "GoPay", type: .digitalWallet)
            ]
        },
        createSubscription: { _ in },
        updateSubscription: { _ in },
        saveSubscription: { _ in }
    )
}

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
