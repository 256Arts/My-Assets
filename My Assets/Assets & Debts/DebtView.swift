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
            Section {
                SymbolPickerLink(symbol: $debt.symbol)
                TextField("Name", text: $nameCopy)
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
                OptionalPercentField("Interest", value: $debt.annualInterestFraction)
                CurrencyField("Amount", value: $debt.currentValue)
            }
            
            Section {
                OptionalCurrencyField("Monthly Payment", value: $debt.monthlyPayment)
            } footer: {
                if let monthsToPayOffString = debt.monthsToPayOffString {
                    Text("\(monthsToPayOffString) remaining")
                        .foregroundStyle(.secondary)
                }
            }
            
            if debt.expense == nil {
                Section {
                    Label {
                        VStack(alignment: .leading) {
                            Text("There is no associated expense for this debt.")
                            Button("Fix") {
                                try? debt.generateExpense()
                            }
                            .buttonStyle(.borderless)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                }
            }
        }
        .navigationTitle("Debt")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onDisappear {
            debt.name = nameCopy
            debt.expense?.name = debt.name
            debt.expense?.symbol = debt.symbol
            debt.expense?.colorName = debt.colorName
            debt.expense?.children?.first(where: { $0.name == "Interest" })?.baseMonthlyCost = debt.monthlyInterest
            debt.expense?.children?.first(where: { $0.name == "Principal" })?.baseMonthlyCost = (debt.monthlyPayment ?? debt.monthlyInterest) - debt.monthlyInterest
        }
    }
}

#Preview {
    DebtView(debt: Debt())
}
