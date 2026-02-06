//
//  NewExpenseView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI
import StoreKit

struct NewExpenseView: View {
    
    var parentExpense: Expense?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) private var requestReview
    
    @Environment(FinancialData.self) private var data
    
    @Bindable var expense = Expense(name: "", symbol: Symbol.defaultSymbol, category: .discretionary, baseAmount: 0)
    @State var cost: Double?
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: Binding(get: {
                    expense.name ?? ""
                }, set: { newValue in
                    expense.name = newValue
                }))
                #if !os(macOS)
                .textInputAutocapitalization(.words)
                #endif
                OptionalCurrencyField("Amount", value: $cost)
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
                if expense.frequency != nil {
                    DatePicker("Starting Date", selection: Binding(get: {
                        expense.startDate ?? .now
                    }, set: { newValue in
                        expense.startDate = newValue
                    }), displayedComponents: .date)
                }
            }
            Section {
                SymbolPicker(selected: Binding(get: {
                    expense.symbol ?? .defaultSymbol
                }, set: { newValue in
                    expense.symbol = newValue
                }))
            }
        }
        .navigationTitle("New Expense")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    self.dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    self.expense.baseAmount = cost
                    modelContext.insert(expense)
                    if let parentExpense = self.parentExpense {
                        expense.parent = parentExpense
//                            parentExpense.children.append(self.expense)
                    } else {
                        self.data.expenses.append(self.expense)
                    }
                    if UserDefaults.standard.incrementItemsCreated() { requestReview() }
                    self.dismiss()
                }
                .disabled(cost == nil)
            }
        }
        .onChange(of: expense.symbol) { _, newValue in
            if (expense.name ?? "").isEmpty {
                expense.name = newValue?.suggestedTitle
            }
        }
    }
}

#Preview {
    NewExpenseView(parentExpense: nil)
}
