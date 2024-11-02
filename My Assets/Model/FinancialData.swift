//
//  FinancialData.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-06.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI

final class FinancialData: ObservableObject {
    
    static let newestFileVersion = 1
    
    @Published var nonStockAssets: [Asset]
    @Published var stocks: [Stock]
    var assets: [Asset] {
        (nonStockAssets + stocks.map({ Asset(stock: $0) })).sorted(by: >)
    }
    
    @Published var debts: [Debt]
    
    @Published var income: [Income]
    var totalLiquidIncome: Double {
        income.filter({ $0.isLiquid == true }).reduce(0, { $0 + ($1.monthlyEarnings ?? 0) })
    }
    var totalPassiveIncome: Double {
        income.filter({ $0.isPassive == true }).reduce(0, { $0 + ($1.monthlyEarnings ?? 0) })
    }
    var totalNonAssetIncome: Double {
        income.filter({ $0.fromAsset == nil }).reduce(0, { $0 + ($1.monthlyEarnings ?? 0) })
    }
    var totalNonAssetPassiveIncome: Double {
        income.filter({ $0.fromAsset == nil && $0.isPassive == true }).reduce(0, { $0 + ($1.monthlyEarnings ?? 0) })
    }
    var totalIncome: Double {
        income.reduce(0, { $0 + ($1.monthlyEarnings ?? 0) })
    }
    
    @Published var expenses: [Expense]
    var totalExpenses: Double {
        expenses.reduce(0, { $0 + $1.monthlyCost(excludingSavings: true) })
    }
    var totalPassiveExpenses: Double {
        expenses.filter({ $0.fromDebt != nil }).reduce(0, { $0 + $1.monthlyCost(excludingSavings: true) })
    }
    
    var avgAnnualNetWorthInterest: Double {
        // Calculate weigted average
        let totalWeight = netWorth(at: .now, type: .natural)
        guard !totalWeight.isZero else { return 0.0 }
        
        var avgInterest = 0.0
        for asset in assets {
            avgInterest += asset.effectiveAnnualInterestFraction * asset.currentValue
        }
        for debt in debts {
            avgInterest -= debt.annualInterestFraction ?? 0 * debt.currentValue
        }
        return avgInterest / totalWeight
    }
    
    func balance(at date: Date) -> Double {
        assets.filter({ $0.isLiquid ?? true }).reduce(0, { $0 + $1.currentValue(at: date) })
    }
    
    enum NetWorthType {
        case working // Standard net worth
        case natural // Only assets, debts, and interest on them. (No human interaction. No human work income, or human expenses.)
        case notWorking // Net worth if you quit your job
    }

    func netWorth(at date: Date, type: NetWorthType) -> Double {
        let components = netWorthComponents(at: date, type: type)
        return components.assets - components.debts
    }
    
    func netWorthComponents(at date: Date, type: NetWorthType) -> (assets: Double, debts: Double) {
        let assetsAtDate = assets.reduce(0, { $0 + $1.currentValue(at: date) })
        let debtsAtDate = debts.reduce(0, { $0 + $1.currentValue(at: date) })
        if abs(date.timeIntervalSinceNow) < 10 {
            return (assetsAtDate, debtsAtDate)
        }
        
        // Calculate all income and expenses within this time, and assume they have the same average interest as the user's current net worth
        // Using formula: Future value of an annuity
        let income: Double = {
            switch type {
            case .working:
                totalNonAssetIncome
            case .natural, .notWorking:
                totalNonAssetPassiveIncome
            }
        }()
        let expenses: Double = {
            switch type {
            case .natural:
                totalPassiveExpenses
            case .working, .notWorking:
                totalExpenses
            }
        }()
        let pmt = income - expenses
        let r = avgAnnualNetWorthInterest / 12
        let n = date.timeIntervalSinceNow / TimeInterval.month
        let fv = pmt * (pow(1 + r, n) - 1) / r
        
        return (assetsAtDate + fv, debtsAtDate)
    }
    
    init(nonStockAssets: [Asset], stocks: [Stock], debts: [Debt], income: [Income], expenses: [Expense]) {
        self.nonStockAssets = nonStockAssets
        self.stocks = stocks
        self.debts = debts
        self.income = income
        self.expenses = expenses.filter { $0.parent == nil }
    }
    
}
