//
//  NewExpenseView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct NewExpenseView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var data: FinancialData
    
    @Binding var parentExpense: Expense?
    
    @StateObject var expense = Expense(name: "", symbol: Symbol.defaultSymbol, monthlyCost: 0)
    @State var cost: Double?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $expense.name)
                        .textInputAutocapitalization(.words)
                    OptionalDoubleField("Monthly Cost ($)", value: $cost, formatter: currencyFormatter)
                }
                Section {
                    SymbolPicker(selected: $expense.symbol)
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
                            if let parentExpense = self.parentExpense {
                                parentExpense.children.append(self.expense)
                                parentExpense.children.sort(by: { $0 > $1 })
                            } else {
                                self.data.nonDebtExpenses.append(self.expense)
                                self.data.nonDebtExpenses.sort(by: { $0 > $1 })
                            }
                            self.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle(expense.name)
        .onChange(of: expense.symbol) { newValue in
            if expense.name.isEmpty {
                expense.name = newValue.suggestedTitle
            }
        }
    }
}

struct NewExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        NewExpenseView(parentExpense: .constant(nil))
    }
}
