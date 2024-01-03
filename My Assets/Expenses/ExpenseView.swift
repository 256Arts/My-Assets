//
//  ExpenseView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
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
                SymbolPickerLink(symbol: $expense.symbol)
                TextField("Name", text: $nameCopy)
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
                OptionalCurrencyField("Monthly Cost", value: $expense.baseMonthlyCost)
                Picker("Category", selection: $expense.category) {
                    ForEach(Expense.Category.allCases) { category in
                        Text(category.name)
                            .tag(category as Expense.Category?)
                    }
                }
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

#Preview {
    ExpenseView(expense: Expense(name: "", symbol: Symbol.defaultSymbol, category: .discretionary, monthlyCost: 9.99))
}
