//
//  FinancialData.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-06.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

final class FinancialData: ObservableObject {
    
    static let newestFileVersion = 1
    
    @Published var nonStockAssets: [Asset] {
       didSet {
           save()
       }
    }
    @Published var stocks: [Stock] {
       didSet {
           save()
       }
    }
    var assets: [Asset] {
        (nonStockAssets + stocks.map({ Asset(stock: $0) })).sorted(by: >)
    }
    
    @Published var debts: [Debt] {
        didSet {
            save()
        }
    }
    
    @Published var nonAssetIncome: [Income] {
       didSet {
           save()
       }
    }
    var income: [Income] {
        (nonAssetIncome + assets.map({ Income(asset: $0) })).filter({ $0.monthlyEarnings != 0 }).sorted(by: >)
    }
    var totalLiquidIncome: Double {
        income.filter({ $0.isLiquid! }).reduce(0, { $0 + $1.monthlyEarnings! })
    }
    var totalIncome: Double {
        income.reduce(0, { $0 + $1.monthlyEarnings! })
    }
    
    @Published var nonDebtExpenses: [Expense] {
        didSet {
            save()
        }
    }
    var expenses: [Expense] {
        (nonDebtExpenses + debts.map({ Expense(debt: $0) })).filter({ $0.monthlyCost != 0 }).sorted(by: >)
    }
    var totalExpenses: Double {
        expenses.reduce(0, { $0 + $1.monthlyCost })
    }
    
    func balance(at date: Date) -> Double {
        assets.filter({ $0.isLiquid ?? true }).reduce(0, { $0 + $1.currentValue(at: date) })
    }
    
    /**
     passive: Whether the future net worth is only interest on your assets, or assumes you continue earning non-passive income and paying non-debt expenses
     */
    func avgAnnualNetWorthInterest(passive: Bool) -> Double {
        let interest = (netWorth(at: Date(timeIntervalSinceNow: .year), passive: passive) / netWorth(at: .now, passive: passive)) - 1.0
        return interest.isFinite ? interest : 0
    }

    /**
     passive: Whether the future net worth is only interest on your assets, or assumes you continue earning non-passive income and paying non-debt expenses
     */
    func netWorth(at date: Date, passive: Bool) -> Double {
        if passive || abs(date.timeIntervalSinceNow) < 10 {
            return assets.reduce(0, { $0 + $1.currentValue(at: date) })  - debts.reduce(0, { $0 + $1.currentValue(at: date) })
        }
        
        // Calculate all income and expenses within this time, and assume they have the same average interest as the user's current net worth
        // Using formula: Future value of an annuity
        let pmt = totalIncome - totalExpenses
        let r = avgAnnualNetWorthInterest(passive: true) / 12
        let n = date.timeIntervalSinceNow / TimeInterval.month
        let fv = pmt * (pow(1 + r, n) - 1) / r
        
        return netWorth(at: .now, passive: true) + fv
    }
    
    init(nonStockAssets: [Asset], stocks: [Stock], debts: [Debt], nonAssetIncome: [Income], nonDebtExpenses: [Expense]) {
        self.nonStockAssets = nonStockAssets
        self.stocks = stocks
        self.debts = debts
        self.nonAssetIncome = nonAssetIncome
        self.nonDebtExpenses = nonDebtExpenses.filter { $0.parent == nil }
    }
    
    func save() {
        // Removed with SwiftData
    }
    
}
