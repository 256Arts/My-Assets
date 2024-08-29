//
//  DebtView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2021-10-27.
//  Copyright © 2021 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct DebtView: View {
    
    @EnvironmentObject var data: FinancialData
    
    @Bindable var debt: Debt
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    
    init(debt: Debt) {
        self.debt = debt
        _nameCopy = State(initialValue: debt.name ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                SymbolPickerLink(symbol: $debt.symbol)
                TextField("Name", text: $nameCopy)
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
                OptionalPercentField("Interest", value: $debt.annualInterestFraction)
                CurrencyField("Amount", value: $debt.currentValue)
            }
            Section {
                OptionalCurrencyField("Monthly Payment", value: $debt.monthlyPayment)
                Picker("Transaction Frequency", selection: $debt.transactionFrequency) {
                    Text("-")
                        .tag(nil as TransactionFrequency?)
                    ForEach(TransactionFrequency.allCases) { freq in
                        Text(freq.rawValue.capitalized)
                            .tag(freq as TransactionFrequency?)
                    }
                }
                if debt.transactionFrequency != nil {
                    DatePicker("Starting Date", selection: Binding(get: {
                        debt.transactionDateStart ?? .now
                    }, set: { newValue in
                        debt.transactionDateStart = newValue
                    }), displayedComponents: .date)
                }
                if let monthsToPayOffString = debt.monthsToPayOffString {
                    Text("\(monthsToPayOffString) remaining")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Debt")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onDisappear {
            debt.name = nameCopy
        }
    }
}

#Preview {
    DebtView(debt: Debt())
}
