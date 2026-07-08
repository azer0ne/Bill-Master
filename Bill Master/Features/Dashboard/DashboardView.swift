//
//  DashboardView.swift
//  BillMaster
//
//  Created by Reza on 27/04/26.
//

import ComposableArchitecture
import SwiftUI

struct DashboardView: View {
    @Bindable var store: StoreOf<DashboardFeature>
    @State private var subscriptionDetailDetent = PresentationDetent.medium
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.regular) {
                    DashboardHeader {
                        store.send(.addSubscriptionTapped)
                    }
                    
                    content
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.screenVertical)
            }
            .background(AppColor.screenBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                store.send(.onAppear)
            }
            .sheet(item: $store.scope(state: \.subscriptionDetail, action: \.subscriptionDetail)) { store in
                SubscriptionDetailView(store: store, selectedDetent: $subscriptionDetailDetent)
                    .presentationDetents([.medium, .large], selection: $subscriptionDetailDetent)
                    .onAppear {
                        subscriptionDetailDetent = .medium
                    }
            }
            .sheet(item: $store.scope(state: \.subscriptionForm, action: \.subscriptionForm)) { store in
                SubscriptionFormView(store: store)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if store.isLoading && store.subscriptions.isEmpty {
            LoadingStateView()
        } else if let errorMessage = store.errorMessage {
            ErrorStateView(message: errorMessage) {
                store.send(.onAppear)
            }
        } else if store.subscriptions.isEmpty {
            EmptyStateView {
                store.send(.addSubscriptionTapped)
            }
        } else {
            subscriptionsContent
        }
    }
    
    private var subscriptionsContent: some View {
        VStack(spacing: AppSpacing.medium) {
            if let subscription = store.prioritySubscription {
                PrioritySubscriptionCard(subscription: subscription)
                    .onTapGesture {
                        store.send(.subscriptionTapped(subscription))
                    }
            }
            
            ForEach(store.remainingSubscriptions) { subscription in
                SubscriptionRowCard(subscription: subscription)
                    .onTapGesture {
                        store.send(.subscriptionTapped(subscription))
                    }
            }
        }
    }
}

private struct DashboardHeader: View {
    let addSubscription: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.regular) {
            Text("Upcoming Bills")
                .font(AppTypography.screenTitle)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)
            
            Spacer(minLength: 12)
            
            Button(action: addSubscription) {
                Image(systemName: "plus")
                    .font(.headline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .controlSize(.regular)
            .accessibilityLabel("Add subscription")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }
}

private struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            ProgressView()
            Text("Loading subscriptions")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
    }
}

private struct ErrorStateView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label("Unable to Load Bills", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 320)
    }
}

private struct EmptyStateView: View {
    let addSubscription: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label("No Upcoming Bills", systemImage: "calendar.badge.plus")
        } description: {
            Text("Add a subscription to start tracking upcoming payments.")
        } actions: {
            Button("Add Subscription", action: addSubscription)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 320)
    }
}

private struct PrioritySubscriptionCard: View {
    let subscription: Subscription
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xLarge) {
            HStack(alignment: .top) {
                CategoryIconView(category: subscription.category, size: 56, symbolSize: 28)
                
                Spacer()
                
                if subscription.nextBillingDate.isUrgentDueDate() {
                    SubscriptionStatusBadge()
                }
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text(subscription.name)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                
                SubscriptionMetadata(subscription: subscription, font: .title3)
            }
            
            HStack {
                Text(CurrencyFormatter.string(amount: subscription.amount, currency: subscription.currency))
                    .font(AppTypography.screenTitle.monospacedDigit())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .layoutPriority(1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColor.tertiaryLabel)
            }
        }
        .padding(AppSpacing.xLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle(.priority)
    }
}

private struct SubscriptionRowCard: View {
    let subscription: Subscription
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        Group {
            if dynamicTypeSize > .large {
                verticalLayout
            } else {
                horizontalLayout
            }
        }
        .padding(.horizontal, AppSpacing.cardHorizontal)
        .padding(.vertical, AppSpacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle(.row)
    }
    
    private var horizontalLayout: some View {
        HStack(spacing: AppSpacing.regular) {
            CategoryIconView(category: subscription.category, size: 48, symbolSize: 23)
                .layoutPriority(1)
            
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(subscription.name)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                
                SubscriptionMetadata(subscription: subscription, font: .system(size: 12))
            }
            .layoutPriority(1)
            
            Spacer(minLength: 8)
            
            VStack(alignment: .trailing, spacing: 8) {
                if subscription.nextBillingDate.isUrgentDueDate() {
                    SubscriptionStatusBadge(size: .small)
                }
                
                Text(CurrencyFormatter.string(amount: subscription.amount, currency: subscription.currency))
                    .font(AppTypography.subtitle.monospacedDigit())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .layoutPriority(1)
            
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.tertiaryLabel)
        }
    }
    
    private var verticalLayout: some View {
        HStack(alignment: .center, spacing: AppSpacing.regular) {
            CategoryIconView(category: subscription.category, size: 48, symbolSize: 23)
            
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text(subscription.name)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                SubscriptionMetadata(subscription: subscription, font: .subheadline)
                
                HStack(spacing: 8) {
                    Text(CurrencyFormatter.string(amount: subscription.amount, currency: subscription.currency))
                        .font(AppTypography.rowValue.monospacedDigit())
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    
                    if subscription.nextBillingDate.isUrgentDueDate() {
                        SubscriptionStatusBadge(size: .small)
                    }
                }
            }
            .layoutPriority(1)
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.tertiaryLabel)
        }
    }
}

private struct SubscriptionMetadata: View {
    let subscription: Subscription
    let font: Font
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(subscription.category.accentColor)
                .frame(width: 8, height: 8)
            
            Text("\(subscription.category.displayName) • \(DueDateFormatter.string(for: subscription.nextBillingDate))")
                .font(font)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    DashboardView(
        store: Store(initialState: DashboardFeature.State()) {
            DashboardFeature()
        } withDependencies: {
            $0.databaseClient = .previewValue
        }
    )
}
