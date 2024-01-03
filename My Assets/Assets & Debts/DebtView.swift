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
            SymbolPickerLink(symbol: $debt.symbol)
            TextField("Name", text: $nameCopy)
                #if !os(macOS)
                .textInputAutocapitalization(.words)
                #endif
            OptionalPercentField("Interest", value: $debt.annualInterestFraction)
            CurrencyField("Amount", value: $debt.currentValue)
            OptionalCurrencyField("Monthly Payment", value: $debt.monthlyPayment)
            if let monthsToPayOffString = debt.monthsToPayOffString {
                Text("\(monthsToPayOffString) remaining")
                    .foregroundStyle(.secondary)
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
