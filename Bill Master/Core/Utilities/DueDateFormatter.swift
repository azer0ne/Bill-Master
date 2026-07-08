//
//  DueDateFormatter.swift
//  BillMaster
//
//  Created by Reza on 13/05/26.
//

import Foundation

enum DueDateFormatter {
    static func string(for date: Date, calendar: Calendar = .current, now: Date = Date()) -> String {
        let days = date.daysUntilDue(calendar: calendar, now: now)
        
        if days == 0 {
            return "Due Today"
        }
        
        if days == 1 {
            return "Due in 1 Day"
        }
        
        if days > 1, days <= 5 {
            return "Due in \(days) Days"
        }
        
        return "Due \(date.formatted(date: .abbreviated, time: .omitted))"
    }
}
