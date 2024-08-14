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
    @Query var upcomingSpends: [UpcomingSpend]
    
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
                    HStack {
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
                        .padding(6)
                        .frame(idealHeight: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                        
                        if spentIncome.isFinite, 0 < spentIncome {
                            VStack(spacing: 0) {
                                Gauge(value: spentIncome) {
                                    EmptyView()
                                } currentValueLabel: {
                                    Text(shortPercentFormatter.string(from: NSNumber(value: spentIncome))!)
                                }
                                .gaugeStyle(.accessoryCircular)
                                .tint(LinearGradient(colors: [.green, .gray, .red], startPoint: .leading, endPoint: .trailing))
                                
                                Text("Spent Income")
                                    .multilineTextAlignment(.center)
                                    .font(.caption)
                            }
                            .padding(6)
                            .frame(idealHeight: .infinity, maxHeight: .infinity)
                            .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .frame(height: 130)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
                    .onDelete(perform: deleteNonDebtExpense)
                    
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

                if !upcomingSpends.isEmpty {
                    Section {
                        ForEach(upcomingSpends) { spend in
                            NavigationLink(value: spend) {
                                LabeledContent(spend.name ?? "", value: currencyFormatter.string(from: NSNumber(value: spend.cost ?? 0)) ?? "")
                            }
                        }
                        .onDelete(perform: deleteUpcomingSpend)
                    } header: {
                        Text("Upcoming Spends")
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
            .navigationDestination(for: UpcomingSpend.self) { spend in
                UpcomingSpendView(spend: spend)
            }
        }
        .sheet(isPresented: self.$showingDetail) {
            NavigationStack {
                NewExpenseView(parentExpense: nil)
            }
        }
    }
    
    private func deleteNonDebtExpense(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(data.nonDebtExpenses[offset])
            data.nonDebtExpenses.remove(at: offset)
        }
    }
    
    private func deleteUpcomingSpend(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(upcomingSpends[offset])
        }
    }
    
}

#Preview {
    ExpensesView()
}
