//
//  IncomeSourceView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct IncomeSourceView: View {
    
    @EnvironmentObject var data: FinancialData
    
    @Bindable var income: Income
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    
    init(income: Income) {
        self.income = income
        _nameCopy = State(initialValue: income.name ?? "")
    }
    
    var body: some View {
        Form {
            SymbolPickerLink(symbol: $income.symbol)
            TextField("Name", text: $nameCopy)
                #if !os(macOS)
                .textInputAutocapitalization(.words)
                #endif
            OptionalCurrencyField("Monthly Earnings", value: $income.monthlyEarnings)
            Toggle("Liquid", isOn: Binding(get: {
                income.isLiquid ?? true
            }, set: { newValue in
                income.isLiquid = newValue
            }))
            Toggle("Passive", isOn: Binding(get: {
                income.isPassive ?? false
            }, set: { newValue in
                income.isPassive = newValue
            }))
            Picker("Transaction Frequency", selection: $income.transactionFrequency) {
                Text("-")
                    .tag(nil as TransactionFrequency?)
                ForEach(TransactionFrequency.allCases) { freq in
                    Text(freq.rawValue.capitalized)
                        .tag(freq as TransactionFrequency?)
                }
            }
            if income.transactionFrequency != nil {
                DatePicker("Starting Date", selection: Binding(get: {
                    income.transactionDateStart ?? .now
                }, set: { newValue in
                    income.transactionDateStart = newValue
                }), displayedComponents: .date)
            }
        }
        .navigationTitle("Income Source")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onDisappear {
            income.name = nameCopy
        }
    }
}

#Preview {
    IncomeSourceView(income: Income(name: "", symbol: Symbol.defaultSymbol, isLiquid: true, monthlyEarnings: 100.00, isPassive: true))
}
