//
//  DebtView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2021-10-27.
//  Copyright © 2021 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct DebtView: View {
    
    @EnvironmentObject var data: FinancialData
    
    @Binding var debt: Debt
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    
    init(debt: Binding<Debt>) {
        _debt = debt
        _nameCopy = State(initialValue: debt.wrappedValue.name ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $nameCopy)
                    .textInputAutocapitalization(.words)
                DoubleField("Interest", value: Binding(get: {
                    debt.annualInterestFraction ?? 0
                }, set: { newValue in
                    debt.annualInterestFraction = newValue
                }), formatter: percentFormatter)
                DoubleField("Amount", value: $debt.currentValue, formatter: currencyFormatter)
                DoubleField("Monthly Payment", value: Binding(get: {
                    debt.monthlyPayment ?? 0
                }, set: { newValue in
                    debt.monthlyPayment = newValue
                }), formatter: currencyFormatter)
            }
            Section {
                SymbolPicker(selected: Binding(get: {
                    debt.symbol ?? .defaultSymbol
                }, set: { newValue in
                    debt.symbol = newValue
                }))
            }
        }
        .navigationTitle("Debt")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            debt.name = nameCopy
            data.debts.sort(by: >)
        }
    }
}

struct DebtView_Previews: PreviewProvider {
    static var previews: some View {
        DebtView(debt: .constant(Debt()))
    }
}
