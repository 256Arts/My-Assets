//
//  MyAssetsApp.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2022-03-28.
//  Copyright © 2022 256 Arts Developer. All rights reserved.
//

import SwiftUI
import SwiftData

let appWhatsNewVersion = 1

@main
struct MyAssetsApp: App {
    
    init() {
        UserDefaults.standard.register()
    }
    
    var body: some Scene {
        WindowGroup {
//            DeleterView()
            RootTabView()
        }
        .defaultSize(width: 500, height: 800)
//        .modelContainer(for: [Asset.self, Debt.self, Stock.self, UpcomingSpend.self, Income.self, Expense.self, CreditCard.self])
        #if DEBUG
        .modelContainer(previewContainer)
        #endif
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}

#if DEBUG
struct DeleterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var nonStockAssets: [Asset]
    @Query var debts: [Debt]
    @Query var stocks: [Stock]
    @Query var nonAssetIncome: [Income]
    @Query var nonDebtExpenses: [Expense]
    var body: some View {
        Text("Deleting preview data...")
            .onAppear {
                for item in nonStockAssets {
                    if previewAssets.contains(where: { $0.name == item.name && $0.currentValue == item.currentValue }) {
                        modelContext.delete(item)
                        print("Delete \(item.name ?? "")")
                    }
                }
                for item in debts {
                    if previewDebts.contains(where: { $0.name == item.name && $0.currentValue == item.currentValue }) {
                        modelContext.delete(item)
                    }
                }
                for item in nonAssetIncome {
                    if previewIncome.contains(where: { $0.name == item.name && $0.monthlyEarnings == item.monthlyEarnings }) {
                        modelContext.delete(item)
                    }
                }
                for item in nonDebtExpenses {
                    if previewExpenses.contains(where: { $0.name == item.name && $0.monthlyCost == item.monthlyCost }) {
                        modelContext.delete(item)
                    }
                }
            }
    }
}
#endif

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    return formatter
}()

let currencyDeltaFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.positivePrefix = "+"
    return formatter
}()

let percentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1
    return formatter
}()

let timeRemainingFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.maximumUnitCount = 1
    formatter.allowedUnits = [.day, .month, .year]
    return formatter
}()
