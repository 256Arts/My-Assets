//
//  ExpensesView.swift
//  My Assets (watchOS) Watch App
//
//  Created by Jayden Irwin on 2023-09-02.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    
    @EnvironmentObject var data: FinancialData
    
    @Query(filter: #Predicate<Expense> {
        $0.parent == nil
    }, sort: [SortDescriptor(\.baseMonthlyCost, order: .reverse)]) var nonDebtExpenses: [Expense]
    
    var body: some View {
        List {
            ForEach(data.expenses.filter({ $0.fromDebt! })) { expense in
                AmountRow(symbol: expense.symbol ?? .defaultSymbol, label: expense.name!, amount: expense.monthlyCost)
            }
            ForEach(nonDebtExpenses) { expense in
                AmountRow(symbol: expense.symbol ?? .defaultSymbol, label: expense.name!, amount: expense.monthlyCost)
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
