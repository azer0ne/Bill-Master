//
//  DatabaseClient.swift
//  BillMaster
//
//  Created by Reza on 21/04/26.
//

import Foundation
import CoreData

public struct DatabaseClient {
    public var fetchSubscriptions: () async throws -> [Subscription]
    public var saveSubscription: (Subscription) async throws -> Void
}

extension DatabaseClient {
    public static var live: DatabaseClient {
        let container = NSPersistentContainer(name: "BillMaster")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load CoreData stack: \(error.localizedDescription)")
            }
        }
        
        return DatabaseClient(
            fetchSubscriptions: {
                try await container.performBackgroundTask { context in
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
                        
                        var paymentMethod: PaymentMethod? = nil
                        if let cdPaymentMethod = cdSubscription.value(forKey: "paymentMethod") as? NSManagedObject,
                           let pId = cdPaymentMethod.value(forKey: "id") as? UUID,
                           let pName = cdPaymentMethod.value(forKey: "name") as? String,
                           let pTypeString = cdPaymentMethod.value(forKey: "type") as? String,
                           let pType = PaymentType(rawValue: pTypeString) {
                            paymentMethod = PaymentMethod(id: pId, name: pName, type: pType)
                        }
                        
                        return Subscription(
                            id: id,
                            name: name,
                            amount: amount,
                            currency: currency,
                            frequency: frequency,
                            category: category,
                            nextBillingDate: nextBillingDate,
                            paymentMethod: paymentMethod
                        )
                    }
                }
            },
            saveSubscription: { subscription in
                try await container.performBackgroundTask { context in
                    let cdSub = NSEntityDescription.insertNewObject(forEntityName: "CDSubscription", into: context)
                    
                    cdSub.setValue(subscription.id, forKey: "id")
                    cdSub.setValue(subscription.name, forKey: "name")
                    cdSub.setValue(subscription.amount, forKey: "amount")
                    cdSub.setValue(subscription.currency.rawValue, forKey: "currency")
                    cdSub.setValue(subscription.frequency.rawValue, forKey: "frequencyValue")
                    cdSub.setValue(subscription.category.rawValue, forKey: "categoryValue")
                    cdSub.setValue(subscription.nextBillingDate, forKey: "nextBillingDate")
                    
                    // Handle PaymentMethod relationship if it exists
                    if let paymentMethod = subscription.paymentMethod {
                        let request = NSFetchRequest<NSManagedObject>(entityName: "CDPaymentMethod")
                        request.predicate = NSPredicate(format: "id == %@", paymentMethod.id as CVarArg)
                        
                        let cdPaymentMethod: NSManagedObject
                        if let existing = try context.fetch(request).first {
                            cdPaymentMethod = existing
                        } else {
                            cdPaymentMethod = NSEntityDescription.insertNewObject(forEntityName: "CDPaymentMethod", into: context)
                            cdPaymentMethod.setValue(paymentMethod.id, forKey: "id")
                            cdPaymentMethod.setValue(paymentMethod.name, forKey: "name")
                            cdPaymentMethod.setValue(paymentMethod.type.rawValue, forKey: "type")
                        }
                        
                        cdSub.setValue(cdPaymentMethod, forKey: "paymentMethod")
                    }
                    
                    if context.hasChanges {
                        try context.save()
                    }
                }
            }
        )
    }
}
