//
//  SubscriptionCategory+Design.swift
//  BillMaster
//
//  Created by Reza on 19/05/26.
//

import SwiftUI

extension SubscriptionCategory {
    var displayName: String {
        switch self {
        case .entertainment:
            return "Entertainment"
        case .utility:
            return "Utilities"
        case .software:
            return "Productivity"
        case .other:
            return "Other"
        }
    }

    var symbolName: String {
        switch self {
        case .entertainment:
            return "music.note"
        case .utility:
            return "cloud"
        case .software:
            return "sparkles"
        case .other:
            return "square.grid.2x2"
        }
    }

    var accentColor: Color {
        switch self {
        case .entertainment:
            return .purple
        case .utility:
            return .orange
        case .software:
            return .blue
        case .other:
            return .gray
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .entertainment:
            return [Color.green, Color.mint]
        case .utility:
            return [Color.blue.opacity(0.7), Color.blue]
        case .software:
            return [Color.blue.opacity(0.75), Color.purple]
        case .other:
            return [Color.gray.opacity(0.7), Color.gray]
        }
    }
}
