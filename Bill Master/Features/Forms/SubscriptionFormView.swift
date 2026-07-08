//
//  SubscriptionFormView.swift
//  BillMaster
//
//  Created by Reza on 13/05/26.
//

import ComposableArchitecture
import SwiftUI
import UIKit

struct SubscriptionFormView: View {
    @Bindable var store: StoreOf<SubscriptionFormFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: FormLayout.sectionSpacing) {
                    Text(store.title)
                        .font(FormTypography.screenTitle)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    
                    VStack(spacing: FormLayout.cardSpacing) {
                        FormFieldCard(title: "SERVICE NAME", minHeight: 90) {
                            TextField("e.g. Netflix", text: $store.name)
                                .font(FormTypography.fieldValue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.next)
                        }
                        
                        FormFieldCard(title: "AMOUNT (IDR)", minHeight: 90) {
                            AmountTextField(
                                text: store.amountText,
                                textDidChange: { store.send(.amountTextChanged($0)) }
                            )
                        }
                        
                        HStack(spacing: FormLayout.cardSpacing) {
                            FormFieldCard(title: "DUE DATE", minHeight: 90) {
                                DueDatePicker(selection: $store.dueDate)
                            }
                            
                            FormFieldCard(title: "BILLING CYCLE", minHeight: 90) {
                                PickerMenu(
                                    title: store.billingFrequency.displayName,
                                    options: BillingFrequency.allCases,
                                    selection: $store.billingFrequency,
                                    label: \.displayName
                                )
                            }
                        }
                        
                        FormFieldCard(title: "PAYMENT METHOD", minHeight: 90) {
                            PaymentMethodPicker(
                                paymentMethods: store.paymentMethods,
                                selection: $store.selectedPaymentMethodID,
                                isLoading: store.isLoadingPaymentMethods
                            )
                        }
                        
                        Toggle(isOn: $store.autoRenew) {
                            VStack(alignment: .leading, spacing: FormLayout.labelSpacing) {
                                Text("Auto-Renew")
                                    .font(FormTypography.fieldValue)
                                    .foregroundStyle(.primary)
                                Text("Recurring payments")
                                    .font(FormTypography.subtitle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.green)
                        .padding(.horizontal, FormLayout.cardHorizontalPadding)
                        .frame(minHeight: 90)
                        .appCardStyle(.regular)
                        
                        FormFieldCard(title: "CATEGORY", minHeight: 180) {
                            VStack(alignment: .leading, spacing: FormLayout.categorySpacing) {
                                Text(store.selectedCategory?.displayName ?? "e.g. Finance")
                                    .font(FormTypography.fieldValue)
                                    .foregroundStyle(store.selectedCategory == nil ? .secondary : .primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                
                                FlowLayout(spacing: FormLayout.chipSpacing, rowSpacing: FormLayout.chipSpacing) {
                                    ForEach(SubscriptionCategory.allCases, id: \.self) { category in
                                        CategoryChip(
                                            title: category.displayName,
                                            isSelected: store.selectedCategory == category
                                        ) {
                                            store.send(.binding(.set(\.selectedCategory, category)))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: FormLayout.cardSpacing) {
                        if let validationError = store.validationError {
                            Text(validationError.message)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if let errorMessage = store.errorMessage {
                            Text(errorMessage)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, FormLayout.screenHorizontalPadding)
                .padding(.top, AppSpacing.xLarge)
                .padding(.bottom, AppSpacing.large)
            }
            
            HStack(spacing: FormLayout.actionButtonSpacing) {
                Button {
                    store.send(.cancelTapped)
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AppActionButtonStyle(kind: .secondary))
                
                
                Button {
                    store.send(.saveTapped)
                } label: {
                    if store.isSaving {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(store.saveButtonTitle)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(AppActionButtonStyle(kind: .primary))
                .disabled(store.isSaving)
            }
            .padding(.horizontal, FormLayout.screenHorizontalPadding)
            .padding(.top, AppSpacing.bottomBarTop)
            .padding(.bottom, AppSpacing.bottomBarBottom)
            .background(AppColor.screenBackground)
        }
        .background(AppColor.screenBackground.ignoresSafeArea())
        .onAppear {
            store.send(.onAppear)
        }
    }

}

private enum FormTypography {
    static let screenTitle = AppTypography.screenTitle
    static let fieldTitle = AppTypography.fieldTitle
    static let fieldValue = AppTypography.fieldValue
    static let amountValue = AppTypography.fieldValue.monospacedDigit()
    static let subtitle = AppTypography.subtitle
    static let chip = AppTypography.chip
    static let actionButton = AppTypography.actionButton
}

private enum FormLayout {
    static let screenHorizontalPadding = AppSpacing.screenHorizontal
    static let sectionSpacing = AppSpacing.medium
    static let cardSpacing = AppSpacing.regular
    static let fieldContentSpacing = AppSpacing.small
    static let labelSpacing = AppSpacing.xSmall
    static let categorySpacing = AppSpacing.medium
    static let chipSpacing = AppSpacing.small
    static let actionButtonSpacing = AppSpacing.medium
    static let cardHorizontalPadding = AppSpacing.cardHorizontal
    static let cardVerticalPadding = AppSpacing.medium
}

private struct FormFieldCard<Content: View>: View {
    let title: String
    let minHeight: CGFloat
    @ViewBuilder let content: Content
    
    init(title: String, minHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.title = title
        self.minHeight = minHeight
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: FormLayout.fieldContentSpacing) {
            Text(title)
                .font(FormTypography.fieldTitle)
                .foregroundStyle(.secondary)
                .tracking(0.6)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, FormLayout.cardHorizontalPadding)
        .padding(.vertical, FormLayout.cardVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: minHeight, alignment: .center)
        .appCardStyle(.regular)
    }
}

private struct AmountTextField: UIViewRepresentable {
    let text: String
    let textDidChange: (String) -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = "0"
        textField.keyboardType = .decimalPad
        textField.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
        textField.textColor = .label
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 12
        textField.clearButtonMode = .whileEditing
        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        context.coordinator.textDidChange = textDidChange

        if textField.text != text {
            textField.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(textDidChange: textDidChange)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var textDidChange: (String) -> Void

        init(textDidChange: @escaping (String) -> Void) {
            self.textDidChange = textDidChange
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let currentText = textField.text ?? ""
            guard let textRange = Range(range, in: currentText) else {
                return false
            }

            let proposedText = currentText.replacingCharacters(in: textRange, with: string)
            let formattedText = SubscriptionFormFeature.State.formattedAmountText(from: proposedText)
            textField.text = formattedText
            textDidChange(formattedText)
            return false
        }

        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            textField.text = ""
            textDidChange("")
            return false
        }
    }
}

private struct DueDatePicker: View {
    @Binding var selection: Date
    @State private var isPickerPresented = false
    
    var body: some View {
        Button {
            isPickerPresented = true
        } label: {
            HStack(spacing: 14) {
                Text(selection.formatted(date: .numeric, time: .omitted))
                    .font(FormTypography.fieldValue)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
                
                Spacer(minLength: 8)
                
                Image(systemName: "calendar")
                    .font(FormTypography.fieldValue)
                    .foregroundStyle(.primary)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .popover(isPresented: $isPickerPresented, arrowEdge: .bottom) {
            VStack(spacing: 12) {
                DatePicker("", selection: $selection, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                
                Button("Done") {
                    isPickerPresented = false
                }
                .font(FormTypography.actionButton)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(AppColor.primaryAction, in: .rect(cornerRadius: AppRadius.chip, style: .continuous))
                .foregroundStyle(.white)
            }
            .padding(AppSpacing.regular)
            .presentationCompactAdaptation(.sheet)
        }
    }
}

private struct PickerMenu<Value: Hashable>: View {
    let title: String
    let options: [Value]
    @Binding var selection: Value
    let label: (Value) -> String
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(label(option)) {
                    selection = option
                }
            }
        } label: {
            HStack {
                Text(title)
                    .font(FormTypography.fieldValue)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 10)
                
                Image(systemName: "chevron.down")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
            }
        }
    }
}

private struct PaymentMethodPicker: View {
    let paymentMethods: IdentifiedArrayOf<PaymentMethod>
    @Binding var selection: PaymentMethod.ID?
    let isLoading: Bool
    
    var body: some View {
        Menu {
            Button("No Payment Method") {
                selection = nil
            }
            
            ForEach(paymentMethods) { paymentMethod in
                Button(paymentMethod.name) {
                    selection = paymentMethod.id
                }
            }
        } label: {
            HStack {
                Text(title)
                    .font(FormTypography.fieldValue)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Spacer(minLength: 10)
                
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                }
            }
        }
    }
    
    private var title: String {
        guard let selection, let paymentMethod = paymentMethods[id: selection] else {
            return "No Payment Method"
        }
        
        return paymentMethod.name
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FormTypography.chip)
                .foregroundStyle(isSelected ? .white : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, AppSpacing.medium)
                .padding(.vertical, AppSpacing.small)
                .background(
                    isSelected ? AppColor.primaryAction : AppColor.screenBackground,
                    in: .rect(cornerRadius: AppRadius.chip, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.chip, style: .continuous)
                        .stroke(AppColor.separator.opacity(0.7), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        let rows = makeRows(width: width, subviews: subviews)
        let height = rows.reduce(CGFloat.zero) { partialResult, row in
            partialResult + row.height
        } + CGFloat(max(rows.count - 1, 0)) * rowSpacing
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = makeRows(width: bounds.width, subviews: subviews)
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += row.height + rowSpacing
        }
    }
    
    private func makeRows(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let proposedWidth = currentRow.width == 0 ? size.width : currentRow.width + spacing + size.width
            
            if proposedWidth > width, !currentRow.indices.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
            }
            
            currentRow.indices.append(index)
            currentRow.width = currentRow.width == 0 ? size.width : currentRow.width + spacing + size.width
            currentRow.height = max(currentRow.height, size.height)
        }
        
        if !currentRow.indices.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private struct Row {
        var indices: [Subviews.Index] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
}

#Preview("Add") {
    SubscriptionFormView(
        store: Store(initialState: SubscriptionFormFeature.State()) {
            SubscriptionFormFeature()
        } withDependencies: {
            $0.databaseClient = .previewValue
        }
    )
}

#Preview("Edit") {
    SubscriptionFormView(
        store: Store(
            initialState: SubscriptionFormFeature.State(
                subscription: Subscription(
                    name: "Gemini Advanced",
                    amount: 309_000,
                    category: .software,
                    nextBillingDate: Date(),
                    paymentMethod: PaymentMethod(name: "BCA Credit Card", type: .creditCard)
                )
            )
        ) {
            SubscriptionFormFeature()
        } withDependencies: {
            $0.databaseClient = .previewValue
        }
    )
}
