//
//  AppActionButtonStyle.swift
//  BillMaster
//
//  Created by Reza on 19/05/26.
//

import SwiftUI

struct AppActionButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case secondary
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.actionButton)
            .foregroundStyle(kind == .primary ? .white : .primary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(minHeight: AppSize.actionButtonMinHeight)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.82 : 1), in: .rect(cornerRadius: AppRadius.button, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous)
                    .stroke(borderColor.opacity(configuration.isPressed ? 0.85 : 1), lineWidth: 1)
            }
            .shadow(color: kind == .primary ? AppColor.primaryAction.opacity(0.22) : .clear, radius: 12, x: 0, y: 8)
    }

    private var backgroundColor: Color {
        switch kind {
        case .primary:
            return AppColor.primaryAction
        case .secondary:
            return AppColor.cardBackground
        }
    }

    private var borderColor: Color {
        switch kind {
        case .primary:
            return AppColor.primaryAction.opacity(0.85)
        case .secondary:
            return AppColor.separator.opacity(0.7)
        }
    }
}
