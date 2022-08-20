//
//  ExpenseView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct ExpenseView: View {
    
    @EnvironmentObject var data: FinancialData
    
    @Binding var expense: Expense
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    @State var showingSubexpense = false
    
    init(expense: Binding<Expense>) {
        _expense = expense
        _nameCopy = State(initialValue: expense.wrappedValue.name)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $nameCopy)
                    .textInputAutocapitalization(.words)
                DoubleField("Monthly Cost ($)", value: $expense.baseMonthlyCost, formatter: currencyFormatter)
            }
            Section {
                Button {
                    showingSubexpense = true
                } label: {
                    Label("Add", systemImage: "plus.circle")
                }
                ForEach($expense.children) { $child in
                    NavigationLink {
                        ExpenseView(expense: $child)
                    } label: {
                        HStack {
                            SymbolImage(symbol: child.symbol)
                            Text(child.name)
                            Spacer()
                            Text(currencyFormatter.string(from: NSNumber(value: child.monthlyCost))!)
                        }
                    }
                }
                .onDelete(perform: delete)
            } header: {
                Text("Subexpenses")
            }
            Section {
                SymbolPicker(selected: $expense.symbol)
            }
        }
        .navigationTitle(nameCopy)
        .sheet(isPresented: self.$showingSubexpense) {
            NewExpenseView(parentExpense: Binding(get: {
                expense
            }, set: { newValue in
                if let newValue = newValue {
                    expense = newValue
                }
            }))
        }
        .onDisappear {
            expense.name = nameCopy
            data.nonDebtExpenses.sort(by: >)
        }
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            expense.children.remove(at: offset)
        }
    }
    
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView(expense: .constant(Expense(name: "", symbol: Symbol.defaultSymbol, monthlyCost: 9.99)))
    }
}
