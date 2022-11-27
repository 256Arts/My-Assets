//
//  NewIncomeSourceView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct NewIncomeSourceView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var data: FinancialData
    
    @State var income = Income(name: "", symbol: Symbol.defaultSymbol, isLiquid: true, monthlyEarnings: 0, isPassive: false)
    @State var earnings: Double?
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $income.name)
                    .textInputAutocapitalization(.words)
                OptionalDoubleField("Monthly Earnings ($)", value: $earnings, formatter: currencyFormatter)
                Toggle("Liquid", isOn: $income.isLiquid)
                Toggle("Passive", isOn: $income.isPassive)
            }
            Section {
                SymbolPicker(selected: $income.symbol)
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
                        self.data.nonAssetIncome.append(self.income)
                        self.data.nonAssetIncome.sort(by: { $0 > $1 })
                        self.dismiss()
                    }
                }
            }
        }
        .navigationTitle(income.name)
        .onChange(of: income.symbol) { newValue in
            if income.name.isEmpty {
                income.name = newValue.suggestedTitle
            }
        }
    }
}

struct NewIncomeSourceView_Previews: PreviewProvider {
    static var previews: some View {
        NewIncomeSourceView()
    }
}
