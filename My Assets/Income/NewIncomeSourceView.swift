//
//  NewIncomeSourceView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI
import StoreKit

struct NewIncomeSourceView: View {
    
    @Environment(\.requestReview) private var requestReview
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Environment(FinancialData.self) private var data
    
    @Bindable var income = Income(name: "", symbol: Symbol.defaultSymbol, isLiquid: true, amount: 0, isPassive: false)
    @State var earnings: Double?
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: Binding(get: {
                    income.name ?? ""
                }, set: { newValue in
                    income.name = newValue
                }))
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
                OptionalCurrencyField("Earnings", value: $earnings)
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
                Picker("Frequency", selection: $income.frequency) {
                    Text("-")
                        .tag(nil as TransactionFrequency?)
                    ForEach(TransactionFrequency.allCases) { freq in
                        Text(freq.rawValue.capitalized)
                            .tag(freq as TransactionFrequency?)
                    }
                }
                if income.frequency != nil {
                    DatePicker("Starting Date", selection: Binding(get: {
                        income.startDate ?? .now
                    }, set: { newValue in
                        income.startDate = newValue
                    }), displayedComponents: .date)
                }
            }
            Section {
                SymbolPicker(selected: Binding(get: {
                    income.symbol ?? .defaultSymbol
                }, set: { newValue in
                    income.symbol = newValue
                }))
            }
        }
        .navigationTitle("New Income")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    self.dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    self.income.amount = earnings
                    modelContext.insert(income)
                    self.data.income.append(self.income)
                    if UserDefaults.standard.incrementItemsCreated() { requestReview() }
                    self.dismiss()
                }
                .disabled(earnings == nil)
            }
        }
        .navigationTitle(income.name ?? "")
        .onChange(of: income.symbol) { _, newValue in
            if (income.name ?? "").isEmpty {
                income.name = newValue?.suggestedTitle
            }
        }
    }
}

#Preview {
    NewIncomeSourceView()
}
