//
//  NewDebtView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2021-10-27.
//  Copyright © 2021 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct NewDebtView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    
    @State var debt = Debt()
    @State var interest: Double?
    @State var value: Double?
    @State var monthlyPayment: Double?
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: Binding(get: {
                    debt.name ?? ""
                }, set: { newValue in
                    debt.name = newValue
                }))
                    .textInputAutocapitalization(.words)
                OptionalDoubleField("Value ($)", value: $value, formatter: currencyFormatter) { inFocus in
                    guard let value = value else { return }
                    if let interest = interest {
                        debt.annualInterestFraction = interest
                        debt.currentValue = value
                    }
                }
                OptionalDoubleField("Annual Interest (%)", value: $interest, formatter: percentFormatter, onEditingChanged: { inFocus in
                    guard let interest = interest, let value = value else { return }
                    debt.annualInterestFraction = interest
                    debt.currentValue = value
                })
                OptionalDoubleField("Monthly Payment ($)", value: $monthlyPayment, formatter: currencyFormatter) { inFocus in
                    guard let monthlyPayment = monthlyPayment else { return }
                    debt.monthlyPayment = monthlyPayment
                }
            }
            Section {
                SymbolPicker(selected: Binding(get: {
                    debt.symbol ?? .defaultSymbol
                }, set: { newValue in
                    debt.symbol = newValue
                }))
            }
        }
        .navigationTitle("Add Debt")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if let value = self.value {
                        let interest = self.interest ?? 0.0
                        self.debt.annualInterestFraction = interest
                        self.debt.currentValue = value
                        modelContext.insert(debt)
                        self.data.debts.append(self.debt)
                        self.data.debts.sort(by: { $0 > $1 })
                        self.dismiss()
                    }
                }
                .disabled(value == nil)
            }
        }
        .onChange(of: debt.symbol) { _, newValue in
            if (debt.name ?? "").isEmpty {
                debt.name = newValue?.suggestedTitle
            }
        }
    }
}

struct NewDebtView_Previews: PreviewProvider {
    static var previews: some View {
        NewDebtView()
    }
}
