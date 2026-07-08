//
//  PaymentType+Design.swift
//  BillMaster
//
//  Created by Reza on 19/05/26.
//

import Foundation

extension PaymentType {
    var symbolName: String {
        switch self {
        case .creditCard:
            return "creditcard"
        case .debitCard:
            return "creditcard.fill"
        case .digitalWallet:
            return "wallet.pass"
        case .bankTransfer:
            return "building.columns"
        }
    }
}
