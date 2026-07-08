//
//  SubscriptionStatusBadge.swift
//  BillMaster
//
//  Created by Reza on 19/05/26.
//

import SwiftUI

struct SubscriptionStatusBadge: View {
    enum Size {
        case regular
        case small
    }

    var size: Size = .regular

    var body: some View {
        Text("URGENT")
            .font(size == .regular ? .footnote.weight(.bold) : .caption2.weight(.bold))
            .foregroundStyle(.red)
            .padding(.horizontal, size == .regular ? 20 : 10)
            .padding(.vertical, size == .regular ? 10 : 5)
            .background(Color.red.opacity(0.1), in: Capsule())
    }
}
