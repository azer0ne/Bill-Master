//
//  SubscriptionDetailView.swift
//  BillMaster
//
//  Created by Reza on 18/05/26.
//

import ComposableArchitecture
import SwiftUI

struct SubscriptionDetailView: View {
    @Bindable var store: StoreOf<SubscriptionDetailFeature>
    @Binding var selectedDetent: PresentationDetent
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: DetailLayout.sectionSpacing) {
                    header
                    
                    if showsExpandedContent {
                        detailGroup
                        
                        if let errorMessage = store.errorMessage {
                            Text(errorMessage)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, DetailLayout.screenHorizontalPadding)
                .padding(.top, AppSpacing.regular)
                .padding(.bottom, AppSpacing.xLarge)
            }
            
            bottomButtons
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.screenBackground.ignoresSafeArea())
    }
    
    private var showsExpandedContent: Bool {
        selectedDetent == .large
    }
    
    private var header: some View {
        VStack(spacing: AppSpacing.medium) {
            CategoryIconView(
                category: store.subscription.category,
                size: 132,
                symbolSize: 54,
                cornerRadius: AppRadius.largeCard + AppSpacing.small,
                shadowRadius: 26,
                shadowOffsetY: 18
            )
            
            VStack(spacing: AppSpacing.medium) {
                Text(store.subscription.name)
                    .font(DetailTypography.headerTitle)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                
                Text(amountSubtitle)
                    .font(DetailTypography.headerSubtitle)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                
                if !showsExpandedContent {
                    Text("Due \(store.subscription.nextBillingDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(AppTypography.fieldValue)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xLarge)
        .padding(.bottom, AppSpacing.small)
    }
    
    private var detailGroup: some View {
        VStack(spacing: 0) {
            DetailRow(
                iconName: store.subscription.paymentMethod?.type.symbolName ?? "creditcard",
                iconForeground: .blue,
                iconBackground: Color.blue.opacity(0.1),
                title: "PAYMENT METHOD",
                value: store.subscription.paymentMethod?.name ?? "No Payment Method",
                showsChevron: true
            )
            
            DetailDivider()
            
            DetailRow(
                iconName: "checkmark.circle",
                iconForeground: .green,
                iconBackground: Color.green.opacity(0.12),
                title: "NEXT BILLING",
                value: store.subscription.nextBillingDate.formatted(date: .abbreviated, time: .omitted)
            )
            
            DetailDivider()
            
            DetailRow(
                iconName: "arrow.triangle.2.circlepath",
                iconForeground: .purple,
                iconBackground: Color.purple.opacity(0.12),
                title: "BILLING CYCLE",
                value: store.subscription.frequency.displayName
            )
            
            DetailDivider()
            
            DetailRow(
                iconName: "tag",
                iconForeground: .white,
                iconBackground: Color.blue.opacity(0.9),
                title: "CATEGORY",
                value: store.subscription.category.displayName
            )
            
            DetailDivider()
            
            DetailRow(
                iconName: "arrow.triangle.2.circlepath",
                iconForeground: .secondary,
                iconBackground: Color.gray.opacity(0.1),
                title: "AUTO-RENEW",
                value: store.subscription.autoRenew ? "Enabled" : "Disabled"
            ) {
                Toggle("", isOn: .constant(store.subscription.autoRenew))
                    .labelsHidden()
                    .tint(.green)
                    .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, DetailLayout.groupHorizontalPadding)
        .padding(.vertical, DetailLayout.groupVerticalPadding)
        .background(AppColor.cardBackground, in: .rect(cornerRadius: AppRadius.largeCard, style: .continuous))
    }
    
    private var bottomButtons: some View {
        HStack(spacing: AppSpacing.medium) {
            Button {
                store.send(.markAsPaidTapped)
            } label: {
                if store.isMarkingAsPaid {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Mark as Paid")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(AppActionButtonStyle(kind: .primary))
            .disabled(store.isMarkingAsPaid)
            
            Button {
                store.send(.editTapped)
            } label: {
                Label("Edit", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AppActionButtonStyle(kind: .secondary))
            .disabled(store.isMarkingAsPaid)
        }
        .padding(.horizontal, DetailLayout.screenHorizontalPadding)
        .padding(.top, AppSpacing.bottomBarTop)
        .padding(.bottom, AppSpacing.bottomBarBottom)
        .background(AppColor.screenBackground)
    }
    
    private var amountSubtitle: String {
        "\(CurrencyFormatter.string(amount: store.subscription.amount, currency: store.subscription.currency)) / \(store.subscription.frequency.periodName)"
    }
}

private enum DetailTypography {
    static let headerTitle = AppTypography.screenTitle
    static let headerSubtitle = AppTypography.rowValue.monospacedDigit()
    static let rowTitle = AppTypography.rowTitle
    static let rowValue = AppTypography.rowValue
    static let actionButton = AppTypography.actionButton
}

private enum DetailLayout {
    static let sectionSpacing = AppSpacing.medium
    static let rowSpacing = AppSpacing.regular
    static let rowTextSpacing = AppSpacing.xSmall
    static let rowMinHeight: CGFloat = 70
    static let iconSize: CGFloat = 58
    static let iconSymbolSize: CGFloat = 22
    static let screenHorizontalPadding = AppSpacing.screenHorizontal
    static let groupHorizontalPadding = AppSpacing.large
    static let groupVerticalPadding = AppSpacing.large
    static let dividerLeadingPadding: CGFloat = 72
    static let dividerVerticalPadding = AppSpacing.medium
}

private struct DetailRow<Trailing: View>: View {
    let iconName: String
    let iconForeground: Color
    let iconBackground: Color
    let title: String
    let value: String
    let showsChevron: Bool
    let trailing: Trailing
    
    init(
        iconName: String,
        iconForeground: Color,
        iconBackground: Color,
        title: String,
        value: String,
        showsChevron: Bool = false,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.iconName = iconName
        self.iconForeground = iconForeground
        self.iconBackground = iconBackground
        self.title = title
        self.value = value
        self.showsChevron = showsChevron
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: DetailLayout.rowSpacing) {
            Image(systemName: iconName)
                .font(.system(size: DetailLayout.iconSymbolSize, weight: .semibold))
                .foregroundStyle(iconForeground)
                .frame(width: DetailLayout.iconSize, height: DetailLayout.iconSize)
                .background(iconBackground, in: .rect(cornerRadius: AppRadius.rowCard - 2, style: .continuous))
            
            VStack(alignment: .leading, spacing: DetailLayout.rowTextSpacing) {
                Text(title)
                    .font(DetailTypography.rowTitle)
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                
                Text(value)
                    .font(DetailTypography.rowValue)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .layoutPriority(1)
            
            Spacer(minLength: 8)
            
            trailing
            
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColor.tertiaryLabel)
            }
        }
        .frame(maxWidth: .infinity, minHeight: DetailLayout.rowMinHeight, alignment: .leading)
    }
}

private extension DetailRow where Trailing == EmptyView {
    init(
        iconName: String,
        iconForeground: Color,
        iconBackground: Color,
        title: String,
        value: String,
        showsChevron: Bool = false
    ) {
        self.init(
            iconName: iconName,
            iconForeground: iconForeground,
            iconBackground: iconBackground,
            title: title,
            value: value,
            showsChevron: showsChevron
        ) {
            EmptyView()
        }
    }
}

private struct DetailDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColor.separator.opacity(0.28))
            .frame(height: 1)
            .padding(.leading, DetailLayout.dividerLeadingPadding)
            .padding(.vertical, DetailLayout.dividerVerticalPadding)
    }
}

#Preview {
    SubscriptionDetailView(
        store: Store(
            initialState: SubscriptionDetailFeature.State(
                subscription: Subscription(
                    name: "Gemini Advanced",
                    amount: 309_000,
                    frequency: .monthly,
                    category: .software,
                    nextBillingDate: Date(),
                    paymentMethod: PaymentMethod(name: "BCA Credit Card", type: .creditCard),
                    autoRenew: true
                )
            )
        ) {
            SubscriptionDetailFeature()
        } withDependencies: {
            $0.databaseClient = .previewValue
        },
        selectedDetent: .constant(.large)
    )
}
