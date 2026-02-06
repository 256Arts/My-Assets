//
//  ExpensesView.swift
//  My Assets (watchOS) Watch App
//
//  Created by 256 Arts Developer on 2023-09-02.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    
    @Environment(FinancialData.self) private var data
    
    @Query(filter: #Predicate<Expense> {
        $0.parent == nil
    }, sort: [SortDescriptor(\.baseAmount, order: .reverse)]) var expenses: [Expense]
    
    var body: some View {
        List {
            ForEach(expenses.filter({ $0.fromDebt != nil })) { expense in
                AmountRow(symbol: expense.symbol ?? .defaultSymbol, label: expense.name!, amount: expense.monthlyCost())
            }
            ForEach(expenses.filter({ $0.fromDebt == nil })) { expense in
                AmountRow(symbol: expense.symbol ?? .defaultSymbol, label: expense.name!, amount: expense.monthlyCost())
            }
            HStack {
                Text("Total")
                Spacer()
                Text(currencyFormatter.string(from: NSNumber(value: data.totalExpenses))!)
            }
            .font(Font.headline)
        }
        .navigationTitle("Expenses")
    }
}

#Preview {
    ExpensesView()
}
