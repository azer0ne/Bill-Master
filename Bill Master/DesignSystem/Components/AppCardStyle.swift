//
//  AppCardStyle.swift
//  BillMaster
//
//  Created by Reza on 19/05/26.
//

import SwiftUI

struct AppCardStyle: ViewModifier {
    enum Kind {
        case regular
        case row
        case priority
    }

    let kind: Kind

    func body(content: Content) -> some View {
        content
            .background(AppColor.cardBackground, in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            }
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffsetY)
    }

    private var cornerRadius: CGFloat {
        switch kind {
        case .regular:
            return AppRadius.card
        case .row:
            return AppRadius.rowCard
        case .priority:
            return AppRadius.largeCard
        }
    }

    private var borderColor: Color {
        switch kind {
        case .regular:
            return AppColor.separator.opacity(0.7)
        case .row:
            return Color.red.opacity(0.14)
        case .priority:
            return Color.red.opacity(0.18)
        }
    }

    private var borderWidth: CGFloat {
        switch kind {
        case .regular:
            return 1
        case .row:
            return 0.6
        case .priority:
            return 0.8
        }
    }

    private var shadowColor: Color {
        switch kind {
        case .regular:
            return .clear
        case .row:
            return Color.black.opacity(0.04)
        case .priority:
            return Color.blue.opacity(0.1)
        }
    }

    private var shadowRadius: CGFloat {
        switch kind {
        case .regular:
            return 0
        case .row:
            return 8
        case .priority:
            return 15
        }
    }

    private var shadowOffsetY: CGFloat {
        switch kind {
        case .regular:
            return 0
        case .row:
            return 5
        case .priority:
            return 12
        }
    }
}

extension View {
    func appCardStyle(_ kind: AppCardStyle.Kind = .regular) -> some View {
        modifier(AppCardStyle(kind: kind))
    }
}
