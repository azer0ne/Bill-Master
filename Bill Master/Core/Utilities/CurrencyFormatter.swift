//
//  CurrencyFormatter.swift
//  BillMaster
//
//  Created by Reza on 13/05/26.
//

import Foundation

enum CurrencyFormatter {
    static func string(amount: Double, currency: Currency) -> String {
        amount.formatted(.currency(code: currency.rawValue).precision(.fractionLength(0)))
    }
}
