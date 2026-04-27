//
//  PaymentMethod.swift
//  BillMaster
//
//  Created by Reza on 22/04/26.
//

import Foundation

public struct PaymentMethod: Equatable, Identifiable {
    public let id: UUID
    public var name: String // "GoPay", "BCA Card", "Personal to Budi"
    public var type: PaymentType
    
    public init(id: UUID = UUID(), name: String, type: PaymentType) {
        self.id = id
        self.name = name
        self.type = type
    }
}

public enum PaymentType: String, Codable {
    case creditCard, debitCard, digitalWallet, bankTransfer
}
