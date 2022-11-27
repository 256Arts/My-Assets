//
//  IncomeSourceView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct IncomeSourceView: View {
    
    @EnvironmentObject var data: FinancialData
    
    @Binding var income: Income
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    
    init(income: Binding<Income>) {
        _income = income
        _nameCopy = State(initialValue: income.wrappedValue.name)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $nameCopy)
                    .textInputAutocapitalization(.words)
                DoubleField("Monthly Earnings ($)", value: $income.monthlyEarnings, formatter: currencyFormatter)
                Toggle("Liquid", isOn: $income.isLiquid)
                Toggle("Passive", isOn: $income.isPassive)
            }
            Section {
                SymbolPicker(selected: $income.symbol)
            }
        }
        .navigationTitle("Income Source")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            income.name = nameCopy
            data.nonAssetIncome.sort(by: >)
        }
    }
}

struct IncomeSourceView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeSourceView(income: .constant(Income(name: "", symbol: Symbol.defaultSymbol, isLiquid: true, monthlyEarnings: 100.00, isPassive: true)))
    }
}
