//
//  NewIncomeSourceView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct NewIncomeSourceView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var data: FinancialData
    
    @State var income = Income(name: "", symbol: Symbol.defaultSymbol, isLiquid: true, monthlyEarnings: 0, isPassive: false)
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
                OptionalCurrencyField("Monthly Earnings", value: $earnings)
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
                    self.income.monthlyEarnings = earnings
                    modelContext.insert(income)
                    self.data.income.append(self.income)
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
