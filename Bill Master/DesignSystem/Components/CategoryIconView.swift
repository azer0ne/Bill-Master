//
//  CategoryIconView.swift
//  BillMaster
//
//  Created by Reza on 19/05/26.
//

import SwiftUI

struct CategoryIconView: View {
    let category: SubscriptionCategory
    let size: CGFloat
    let symbolSize: CGFloat
    var cornerRadius: CGFloat?
    var shadowRadius: CGFloat = 10
    var shadowOffsetY: CGFloat = 7

    var body: some View {
        Image(systemName: category.symbolName)
            .font(.system(size: symbolSize, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius ?? size * 0.28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: category.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: category.accentColor.opacity(0.22), radius: shadowRadius, x: 0, y: shadowOffsetY)
    }
}
