//
//  NewIncomeSourceView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
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
                    .textInputAutocapitalization(.words)
                OptionalDoubleField("Monthly Earnings ($)", value: $earnings, formatter: currencyFormatter)
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
        .navigationTitle("Add Income")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    self.dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if let earnings = self.earnings {
                        self.income.monthlyEarnings = earnings
                        modelContext.insert(income)
                        self.data.nonAssetIncome.append(self.income)
                        self.data.nonAssetIncome.sort(by: { $0 > $1 })
                        self.dismiss()
                    }
                }
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

struct NewIncomeSourceView_Previews: PreviewProvider {
    static var previews: some View {
        NewIncomeSourceView()
    }
}
