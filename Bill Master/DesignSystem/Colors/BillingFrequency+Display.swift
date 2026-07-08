//
//  BillingFrequency+Display.swift
//  BillMaster
//
//  Created by Reza on 19/05/26.
//

import Foundation

extension BillingFrequency {
    var displayName: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .quarterly:
            return "Quarterly"
        case .yearly:
            return "Yearly"
        }
    }

    var periodName: String {
        switch self {
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        case .quarterly:
            return "quarter"
        case .yearly:
            return "year"
        }
    }
}
