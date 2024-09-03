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
    @State var transactionFrequency: TransactionFrequency?
    @State var transactionDateStart: Date?
    
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
            }
            Section {
                OptionalCurrencyField("Monthly Payment", value: $monthlyPayment)
                Picker("Transaction Frequency", selection: $transactionFrequency) {
                    Text("-")
                        .tag(nil as TransactionFrequency?)
                    ForEach(TransactionFrequency.allCases) { freq in
                        Text(freq.rawValue.capitalized)
                            .tag(freq as TransactionFrequency?)
                    }
                }
                if transactionFrequency != nil {
                    DatePicker("Starting Date", selection: Binding(get: {
                        transactionDateStart ?? .now
                    }, set: { newValue in
                        transactionDateStart = newValue
                    }), displayedComponents: .date)
                }
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
                    try? addDebtAndDismiss()
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
        .onChange(of: monthlyPayment) { _, newValue in
            debt.monthlyPayment = newValue
        }
        .onChange(of: debt.symbol) { _, newValue in
            if (debt.name ?? "").isEmpty {
                debt.name = newValue?.suggestedTitle
            }
        }
    }
    
    private func addDebtAndDismiss() throws {
        guard let value else { return }
        
        let interest = self.interest ?? 0.0
        self.debt.annualInterestFraction = interest
        self.debt.currentValue = value
        
        try? self.debt.generateExpense(transactionFrequency: transactionFrequency, transactionDateStart: transactionDateStart)
        
        modelContext.insert(debt)
        if let parentAsset {
            debt.asset = parentAsset
        } else {
            self.data.debts.append(self.debt)
//            self.data.expenses.append(expense)
        }
        
        dismiss()
    }
}

#Preview {
    NewDebtView()
}
