//
//  ContentView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-06.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import WelcomeKit
import SwiftData
import SwiftUI

struct RootTabView: View {
    
    enum Tabs: Identifiable {
        case summary, assetsAndDebts, income, expenses, creditCards
        
        var id: Self { self }
    }
    
    let welcomeFeatures = [
        WelcomeFeature(image: Image(systemName: "banknote"), title: "Your Assets", body: "Track investments you own."),
        WelcomeFeature(image: Image(systemName: "tray.and.arrow.down"), title: "Income", body: "Track monthly income items."),
        WelcomeFeature(image: Image(systemName: "tray.and.arrow.up"), title: "Expenses", body: "Track monthly expense items.")
    ]
    
    @AppStorage(UserDefaults.Key.whatsNewVersion) var whatsNewVersion = 0
    @Query var nonStockAssets: [Asset]
    @Query var debts: [Debt]
    @Query var stocks: [Stock]
    @Query var income: [Income]
    @Query var expenses: [Expense]
    
    @State var selectedTab: Tabs = .summary
    @State var showingWelcome = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Summary", systemImage: "chart.line.uptrend.xyaxis", value: .summary) {
                SummaryView()
            }
            Tab("Assets/Debts", systemImage: "banknote", value: .assetsAndDebts) {
                AssetsAndDebtsView()
            }
            Tab("Income", systemImage: "tray.and.arrow.down", value: .income) {
                IncomeView()
            }
            Tab("Expenses", systemImage: "tray.and.arrow.up", value: .expenses) {
                ExpensesView()
            }
            Tab("Credit Cards", systemImage: "creditcard", value: .creditCards) {
                CreditCardList()
            }
        }
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
        .onAppear {
            if whatsNewVersion < appWhatsNewVersion {
                showingWelcome = true
            }
        }
        .sheet(isPresented: $showingWelcome, onDismiss: {
            if whatsNewVersion < appWhatsNewVersion {
                whatsNewVersion = appWhatsNewVersion
            }
        }, content: {
            WelcomeView(isFirstLaunch: whatsNewVersion == 0, appName: "My Assets", features: welcomeFeatures)
        })
        .environmentObject(financialData)
    }
    
    private var financialData: FinancialData {
        FinancialData(nonStockAssets: nonStockAssets, stocks: stocks, debts: debts, income: income, expenses: expenses)
    }
}

#Preview {
    RootTabView()
}
