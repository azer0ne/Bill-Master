//
//  PaymentMethodIndicator.swift
//  BillMaster
//
//  Created by Reza on 19/05/26.
//

import SwiftUI

struct PaymentMethodIndicator: View {
    let type: PaymentType?

    var body: some View {
        Image(systemName: type?.symbolName ?? "creditcard")
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(.blue)
            .frame(width: 58, height: 58)
            .background(Color.blue.opacity(0.1), in: .rect(cornerRadius: AppRadius.rowCard - 2, style: .continuous))
    }
}
