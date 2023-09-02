//
//  NewExpenseView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct NewExpenseView: View {
    
    var parentExpense: Expense?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var data: FinancialData
    
    @Bindable var expense = Expense(name: "", symbol: Symbol.defaultSymbol, monthlyCost: 0)
    @State var cost: Double?
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: Binding(get: {
                    expense.name ?? ""
                }, set: { newValue in
                    expense.name = newValue
                }))
                    .textInputAutocapitalization(.words)
                OptionalDoubleField("Monthly Cost ($)", value: $cost, formatter: currencyFormatter)
            }
            Section {
                SymbolPicker(selected: Binding(get: {
                    expense.symbol ?? .defaultSymbol
                }, set: { newValue in
                    expense.symbol = newValue
                }))
            }
        }
        .navigationTitle("Add Expense")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    self.dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if let cost = self.cost {
                        self.expense.baseMonthlyCost = cost
                        modelContext.insert(expense)
                        if let parentExpense = self.parentExpense {
                            expense.parent = parentExpense
//                            parentExpense.children.append(self.expense)
//                            parentExpense.children.sort(by: { $0 > $1 })
                        } else {
                            self.data.nonDebtExpenses.append(self.expense)
                            self.data.nonDebtExpenses.sort(by: { $0 > $1 })
                        }
                        self.dismiss()
                    }
                }
            }
        }
        .onChange(of: expense.symbol) { _, newValue in
            if (expense.name ?? "").isEmpty {
                expense.name = newValue?.suggestedTitle
            }
        }
    }
}

struct NewExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        NewExpenseView(parentExpense: nil)
    }
}
