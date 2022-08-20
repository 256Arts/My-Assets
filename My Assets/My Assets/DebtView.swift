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
        _nameCopy = State(initialValue: debt.wrappedValue.name)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $nameCopy)
                    .textInputAutocapitalization(.words)
                DoubleField("Interest", value: $debt.annualInterestFraction, formatter: percentFormatter)
                DoubleField("Amount", value: $debt.currentValue, formatter: currencyFormatter)
                DoubleField("Monthly Payment", value: $debt.monthlyPayment, formatter: currencyFormatter)
            }
            Section {
                SymbolPicker(selected: $debt.symbol)
            }
        }
        .navigationTitle(nameCopy)
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
