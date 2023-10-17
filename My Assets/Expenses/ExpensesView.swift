//
//  ExpensesView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    
    @Query(filter: #Predicate<Expense> {
        $0.parent == nil
    }, sort: [SortDescriptor(\.baseMonthlyCost, order: .reverse)]) var nonDebtExpenses: [Expense]
    
    @State var showingDetail = false
    
    var spentIncome: Double {
        data.totalExpenses / data.totalLiquidIncome
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(nonDebtExpenses) { expense in
                        NavigationLink(value: expense) {
                            VStack(spacing: 8) {
                                AmountRow(symbol: expense.symbol ?? .defaultSymbol, label: expense.name ?? "", amount: expense.monthlyCost)
                                ForEach(expense.children?.sorted(by: >) ?? []) { child in
                                    AmountRow(symbol: child.symbol ?? .defaultSymbol, label: child.name ?? "", amount: child.monthlyCost)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 32)
                                }
                            }
                        }
                    }
                    .onDelete(perform: delete)
                    ForEach(data.expenses.filter({ $0.fromDebt! })) { expense in
                        AmountRow(symbol: expense.symbol ?? .defaultSymbol, label: expense.name ?? "", amount: expense.monthlyCost)
                    }
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(currencyFormatter.string(from: NSNumber(value: data.totalExpenses))!)
                    }
                    .font(Font.headline)
                }
                if spentIncome.isFinite {
                    Section {
                        Gauge(value: spentIncome) {
                            Text("Spent Income")
                        } currentValueLabel: {
                            Text("Spent Income: \(percentFormatter.string(from: NSNumber(value: spentIncome))!)")
                        }
                        .gaugeStyle(.accessoryLinear)
                        .tint(LinearGradient(colors: [.green, .gray, .red], startPoint: .leading, endPoint: .trailing))
                    }
                }
            }
            .symbolVariant(.fill)
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        self.showingDetail.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                            .symbolVariant(.fill)
                    }
                }
            }
            .navigationDestination(for: Expense.self) { expense in
                ExpenseView(expense: expense)
            }
        }
        .sheet(isPresented: self.$showingDetail) {
            NavigationStack {
                NewExpenseView(parentExpense: nil)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(data.nonDebtExpenses[offset])
            data.nonDebtExpenses.remove(at: offset)
        }
    }
    
}

struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesView()
    }
}
