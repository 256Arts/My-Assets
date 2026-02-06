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
    @Environment(FinancialData.self) private var data
    
    @Bindable var expense: Expense
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    @State var showingSubexpense = false
    
    var children: [Expense] {
        expense.children?.sorted() ?? []
    }
    
    init(expense: Expense) {
        self.expense = expense
        _nameCopy = State(initialValue: expense.name ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                SymbolPickerLink(symbol: $expense.symbol)
                    .disabled(expense.fromDebt != nil)
                TextField("Name", text: $nameCopy)
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
                    .disabled(expense.fromDebt != nil)
                OptionalCurrencyField("Amount", value: $expense.baseAmount)
                    .disabled(expense.fromDebt != nil)
                Picker("Category", selection: $expense.category) {
                    ForEach(Expense.Category.allCases) { category in
                        Text(category.name)
                            .tag(category as Expense.Category?)
                    }
                }
                Picker("Frequency", selection: $expense.frequency) {
                    Text("-")
                        .tag(nil as TransactionFrequency?)
                    ForEach(TransactionFrequency.allCases) { freq in
                        Text(freq.rawValue.capitalized)
                            .tag(freq as TransactionFrequency?)
                    }
                }
                .disabled(expense.fromDebt != nil)
                if expense.frequency != nil {
                    DatePicker("Starting Date", selection: Binding(get: {
                        expense.startDate ?? .now
                    }, set: { newValue in
                        expense.startDate = newValue
                    }), displayedComponents: .date)
                }
            }
            
            Section("Subexpenses") {
                if expense.fromDebt == nil {
                    Button("Add", systemImage: "plus.circle") {
                        showingSubexpense = true
                    }
                    
                    ForEach(children) { child in
                        NavigationLink(value: child) {
                            AmountRow(symbol: child.symbol ?? .defaultSymbol, label: child.name ?? "", amount: child.monthlyCost())
                        }
                    }
                    .onDelete(perform: delete)
                } else {
                    ForEach(children) { child in
                        AmountRow(symbol: child.symbol ?? .defaultSymbol, label: child.name ?? "", amount: child.monthlyCost())
                    }
                }
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
    ExpenseView(expense: Expense(name: "", symbol: Symbol.defaultSymbol, category: .discretionary, baseAmount: 9.99))
}
