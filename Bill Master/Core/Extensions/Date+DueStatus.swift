//
//  Date+DueStatus.swift
//  BillMaster
//
//  Created by Reza on 13/05/26.
//

import Foundation

extension Date {
    func daysUntilDue(calendar: Calendar = .current, now: Date = Date()) -> Int {
        let startOfToday = calendar.startOfDay(for: now)
        let dueDate = calendar.startOfDay(for: self)
        return calendar.dateComponents([.day], from: startOfToday, to: dueDate).day ?? 0
    }
    
    func isUrgentDueDate(calendar: Calendar = .current, now: Date = Date()) -> Bool {
        let days = daysUntilDue(calendar: calendar, now: now)
        return days >= 0 && days <= 5
    }
}
