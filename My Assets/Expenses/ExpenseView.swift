//
//  ExpenseView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct ExpenseView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    
    @Bindable var expense: Expense
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    @State var showingSubexpense = false
    
    init(expense: Expense) {
        self.expense = expense
        _nameCopy = State(initialValue: expense.name ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $nameCopy)
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
                DoubleField("Monthly Cost ($)", value: Binding(get: {
                    expense.baseMonthlyCost ?? 0
                }, set: { newValue in
                    expense.baseMonthlyCost = newValue
                }), formatter: currencyFormatter)
            }
            Section {
                Button {
                    showingSubexpense = true
                } label: {
                    Label("Add", systemImage: "plus.circle")
                }
                ForEach(expense.children ?? []) { child in
                    NavigationLink(value: child) {
                        AmountRow(symbol: child.symbol ?? .defaultSymbol, label: child.name ?? "", amount: child.monthlyCost)
                    }
                }
                .onDelete(perform: delete)
            } header: {
                Text("Subexpenses")
            }
            Section {
                SymbolPicker(selected: Binding(get: {
                    expense.symbol ?? .defaultSymbol
                }, set: { newValue in
                    expense.symbol = newValue
                }))
            }
        }
        .navigationTitle("Expense")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: self.$showingSubexpense) {
            NavigationStack {
                NewExpenseView(parentExpense: expense)
            }
        }
        .onDisappear {
            expense.name = nameCopy
        }
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            if let children = expense.children {
                modelContext.delete(children[offset])
            }
//            expense.children.remove(at: offset)
        }
    }
    
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView(expense: Expense(name: "", symbol: Symbol.defaultSymbol, monthlyCost: 9.99))
    }
}
