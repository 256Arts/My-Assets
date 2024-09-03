//
//  RootTabView.swift
//  My Assets (watchOS) Watch App
//
//  Created by 256 Arts Developer on 2023-07-28.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftData
import SwiftUI

struct RootTabView: View {
    
    private enum Tab: Identifiable, CaseIterable {
        case summary, assetsAndDebts, income, expenses
        
        var id: Self { self }
        var title: String {
            switch self {
            case .summary:
                "Summary"
            case .assetsAndDebts:
                "Assets/Debts"
            case .income:
                "Income"
            case .expenses:
                "Expenses"
            }
        }
        var iconName: String {
            switch self {
            case .summary:
                "chart.line.uptrend.xyaxis"
            case .assetsAndDebts:
                "banknote"
            case .income:
                "tray.and.arrow.down"
            case .expenses:
                "tray.and.arrow.up"
            }
        }
        var color: Color {
            switch self {
            case .summary, .assetsAndDebts:
                .blue
            case .income:
                .green
            case .expenses:
                .red
            }
        }
    }
    
    @Query var nonStockAssets: [Asset]
    @Query var debts: [Debt]
    @Query var stocks: [Stock]
    @Query var nonAssetIncome: [Income]
    @Query var expenses: [Expense]
    
    @State private var selectedTab: Tab?
    
    var body: some View {
        NavigationStack {
            List(Tab.allCases, selection: $selectedTab) { tab in
                Label(tab.title, systemImage: tab.iconName)
                    .symbolVariant(.fill)
                    .foregroundStyle(tab.color)
            }
            .navigationTitle("My Assets")
            .navigationDestination(item: $selectedTab) { tab in
                switch selectedTab {
                case .summary:
                    SummaryView()
                case .assetsAndDebts:
                    AssetsAndDebtsView()
                case .income:
                    IncomeView()
                case .expenses:
                    ExpensesView()
                case nil:
                    EmptyView()
                }
            }
        }
        .environmentObject(financialData)
    }
    
    private var financialData: FinancialData {
        FinancialData(nonStockAssets: nonStockAssets, stocks: stocks, debts: debts, nonAssetIncome: nonAssetIncome, expenses: expenses)
    }
}

#Preview {
    RootTabView()
}
