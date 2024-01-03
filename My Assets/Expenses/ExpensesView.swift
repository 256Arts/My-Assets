//
//  ExpensesView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI
import SwiftData
import Charts

struct ExpensesView: View {
    
    struct SectorData: Plottable, Identifiable {
        
        let category: Expense.Category
        var id: Expense.Category { category }
        let amount: Double
        var primitivePlottable: Double { amount }
        
        init(category: Expense.Category, amount: Double) {
            self.category = category
            self.amount = amount
        }
        
        init?(primitivePlottable: Double) { nil }
    }
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    
    @Query(filter: #Predicate<Expense> {
        $0.parent == nil
    }, sort: [SortDescriptor(\.baseMonthlyCost, order: .reverse)]) var nonDebtRootExpenses: [Expense]
    @Query var nonDebtExpenses: [Expense]
    @Query var debts: [Debt]
    
    @State var showingDetail = false
    
    var pieChartData: [SectorData] {
        let allExpenses = nonDebtExpenses + debts.map({ Expense(debt: $0) })
        return Expense.Category.allCases.map { category in
            SectorData(category: category, amount: allExpenses.filter({ $0.category == category }).reduce(0.0, { $0 + ($1.baseMonthlyCost ?? 0.0) }))
        }
    }
    
    var spentIncome: Double {
        data.totalExpenses / data.totalLiquidIncome
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Chart(pieChartData) { sector in
                        SectorMark(angle: .value("Value", sector.amount), innerRadius: .ratio(0.5), angularInset: 1)
                            .foregroundStyle(by: .value("Category", sector.category.name))
                            .cornerRadius(4)
//                            .annotation(position: .overlay) {
//                                sector.category.icon
//                                    .symbolVariant(.fill)
//                                    .foregroundStyle(Color.white)
//                                    .shadow(radius: 8)
//                            }
                    }
                    .chartLegend(position: .trailing)
                    .chartForegroundStyleScale(range: pieChartData.map({ $0.category.color }))
                    .frame(height: 110)
                }
                Section {
                    ForEach(nonDebtRootExpenses) { expense in
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
                if spentIncome.isFinite, 0 < spentIncome {
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

#Preview {
    ExpensesView()
}
