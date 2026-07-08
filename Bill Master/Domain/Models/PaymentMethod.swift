//
//  PaymentMethod.swift
//  BillMaster
//
//  Created by Reza on 22/04/26.
//

import Foundation

nonisolated public struct PaymentMethod: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var type: PaymentType
    
    public init(id: UUID = UUID(), name: String, type: PaymentType) {
        self.id = id
        self.name = name
        self.type = type
    }
}

nonisolated public enum PaymentType: String, Codable, Sendable, CaseIterable {
    case creditCard, debitCard, digitalWallet, bankTransfer
}
