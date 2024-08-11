//
//  NewDebtView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2021-10-27.
//  Copyright © 2021 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct NewDebtView: View {
    
    var parentAsset: Asset?
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    
    @State var debt = Debt()
    @State var interest: Double?
    @State var value: Double?
    @State var minimumMonthlyPayment: Double?
    @State var monthlyPayment: Double?
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: Binding(get: {
                    debt.name ?? ""
                }, set: { newValue in
                    debt.name = newValue
                }))
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
                OptionalCurrencyField("Value", value: $value)
                OptionalPercentField("Annual Interest", value: $interest)
                OptionalCurrencyField("Minimum Monthly Payment", value: $minimumMonthlyPayment)
                OptionalCurrencyField("Monthly Payment", value: $monthlyPayment)
            }
            Section {
                SymbolPicker(selected: Binding(get: {
                    debt.symbol ?? .defaultSymbol
                }, set: { newValue in
                    debt.symbol = newValue
                }))
            }
        }
        .navigationTitle("New Debt")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if let value = self.value {
                        let interest = self.interest ?? 0.0
                        self.debt.annualInterestFraction = interest
                        self.debt.currentValue = value
                        modelContext.insert(debt)
                        if let parentAsset {
                            debt.asset = parentAsset
                        } else {
                            self.data.debts.append(self.debt)
                        }
                        self.dismiss()
                    }
                }
                .disabled(value == nil)
            }
        }
        .onChange(of: value) { _, newValue in
            guard let newValue else { return }
            debt.currentValue = newValue
        }
        .onChange(of: interest) { _, newValue in
            debt.annualInterestFraction = newValue
        }
        .onChange(of: minimumMonthlyPayment) { _, newValue in
            debt.minimumMonthlyPayment = newValue
            if monthlyPayment?.isZero ?? true {
                monthlyPayment = newValue
            }
        }
        .onChange(of: monthlyPayment) { _, newValue in
            debt.monthlyPayment = newValue
        }
        .onChange(of: debt.symbol) { _, newValue in
            if (debt.name ?? "").isEmpty {
                debt.name = newValue?.suggestedTitle
            }
        }
    }
}

#Preview {
    NewDebtView()
}
