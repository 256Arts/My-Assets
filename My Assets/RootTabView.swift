//
//  ContentView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-06.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftData
import SwiftUI

struct RootTabView: View {
    
    enum Tabs: String, Identifiable {
        case summary, assetsAndDebts, income, expenses, creditCards
        
        var id: String { rawValue }
    }
    
    @Query var nonStockAssets: [Asset]
    @Query var debts: [Debt]
    @Query var stocks: [Stock]
    @Query var income: [Income]
    @Query var expenses: [Expense]
    
    @AppStorage(UserDefaults.Key.tabViewCustomization) var tabViewCustomization: TabViewCustomization
    
    @State var selectedTab: Tabs = .summary
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Summary", systemImage: "chart.line.uptrend.xyaxis", value: .summary) {
                SummaryView()
            }
            .customizationID(Tabs.summary.id)
            Tab("Assets/Debts", systemImage: "house", value: .assetsAndDebts) {
                AssetsAndDebtsView()
            }
            .customizationID(Tabs.assetsAndDebts.id)
            Tab("Income", systemImage: "tray.and.arrow.down", value: .income) {
                IncomeView()
            }
            .customizationID(Tabs.income.id)
            Tab("Expenses", systemImage: "tray.and.arrow.up", value: .expenses) {
                ExpensesView()
            }
            .customizationID(Tabs.expenses.id)
            Tab("Credit Cards", systemImage: "creditcard", value: .creditCards) {
                CreditCardList()
            }
            .customizationID(Tabs.creditCards.id)
        }
        #if os(macOS)
        .tabViewStyle(.sidebarAdaptable)
        #endif
        .tabViewCustomization($tabViewCustomization)
        .accentColor({
            switch selectedTab {
            case .summary, .assetsAndDebts, .creditCards:
                return nil
            case .income:
                return .green
            case .expenses:
                return .red
            }
        }())
        .environmentObject(financialData)
    }
    
    private var financialData: FinancialData {
        FinancialData(nonStockAssets: nonStockAssets, stocks: stocks, debts: debts, income: income, expenses: expenses)
    }
}

#Preview {
    RootTabView()
}
