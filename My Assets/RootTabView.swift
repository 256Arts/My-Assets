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
    
    enum Tab {
        case summary, assetsAndDebts, income, expenses, creditCards
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
    @Query var nonAssetIncome: [Income]
    @Query var nonDebtExpenses: [Expense]
    
    @State var selectedTab: Tab = .summary
    @State var showingWelcome = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.summary)
            AssetsAndDebtsView()
                .tabItem {
                    Label("Assets/Debts", systemImage: "banknote")
                }
                .tag(Tab.assetsAndDebts)
            IncomeView()
                .tabItem {
                    Label("Income", systemImage: "tray.and.arrow.down")
                }
                .tag(Tab.income)
            ExpensesView()
                .tabItem {
                    Label("Expenses", systemImage: "tray.and.arrow.up")
                }
                .tag(Tab.expenses)
            CreditCardList()
                .tabItem {
                    Label("Credit Cards", systemImage: "creditcard")
                }
                .tag(Tab.creditCards)
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
        FinancialData(nonStockAssets: nonStockAssets, stocks: stocks, debts: debts, nonAssetIncome: nonAssetIncome, nonDebtExpenses: nonDebtExpenses)
    }
}

#Preview {
    RootTabView()
}
