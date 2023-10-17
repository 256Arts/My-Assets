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
    
    @Bindable var income: Income
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    
    init(income: Income) {
        self.income = income
        _nameCopy = State(initialValue: income.name ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $nameCopy)
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
                DoubleField("Monthly Earnings ($)", value: Binding(get: {
                    income.monthlyEarnings ?? 0
                }, set: { newValue in
                    income.monthlyEarnings = newValue
                }), formatter: currencyFormatter)
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
        .navigationTitle("Income Source")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onDisappear {
            income.name = nameCopy
        }
    }
}

struct IncomeSourceView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeSourceView(income: Income(name: "", symbol: Symbol.defaultSymbol, isLiquid: true, monthlyEarnings: 100.00, isPassive: true))
    }
}
