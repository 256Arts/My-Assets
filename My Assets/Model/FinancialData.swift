//
//  FinancialData.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-06.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI

@Observable
final class FinancialData {
    
    static let newestFileVersion = 1
    
    var nonStockAssets: [Asset]
    var stocks: [Stock]
    var assets: [Asset] {
        (nonStockAssets + stocks.map({ Asset(stock: $0) })).sorted(by: >)
    }
    
    var debts: [Debt]
    
    var income: [Income]
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
    
    var expenses: [Expense]
    var totalExpenses: Double {
        expenses.reduce(0, { $0 + $1.monthlyCost(excludingSavings: true) })
    }
    var totalPassiveExpenses: Double {
        expenses.filter({ $0.fromDebt != nil }).reduce(0, { $0 + $1.monthlyCost(excludingSavings: true) })
    }
    
    var avgAnnualNetWorthInterest: Double {
        // Weighted by net worth, so this is a return-on-equity figure: it is amplified by
        // leverage (debt). It is the rate at which net worth grows on its own, and is the
        // headline "YoY" shown on the net-worth chart.
        let totalWeight = netWorth(at: .now, type: .natural)
        guard !totalWeight.isZero else { return 0.0 }

        var avgInterest = 0.0
        for asset in assets {
            avgInterest += asset.effectiveAnnualInterestFraction * asset.currentValue
        }
        for debt in debts {
            avgInterest -= (debt.annualInterestFraction ?? 0) * debt.currentValue
        }
        return avgInterest / totalWeight
    }

    var avgAnnualSavingsInterest: Double {
        // Blended interest rate earned across all assets, weighted by their value. Unlike
        // `avgAnnualNetWorthInterest` (return on equity), this is NOT leverage-amplified.
        // For the long-term birds-eye projection, savings are assumed to be deployed across
        // the whole portfolio over time, so this is the rate used to compound future savings.
        let totalAssets = assets.reduce(0.0, { $0 + $1.currentValue })
        guard !totalAssets.isZero else { return 0.0 }

        let weightedInterest = assets.reduce(0.0) { sum, asset in
            let rate = asset.effectiveAnnualInterestFraction
            return sum + (rate.isFinite ? rate : 0) * asset.currentValue
        }
        return weightedInterest / totalAssets
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
        
        // Within 10 seconds of now
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
        // New savings earn the (un-leveraged) rate on liquid assets, not the leveraged
        // return on equity — assets/debts above are already projected at their own rates.
        let r = avgAnnualSavingsInterest / 12
        let n = date.timeIntervalSinceNow / TimeInterval.month
        // Future value of an annuity. When the rate is zero the standard formula divides
        // by zero (0/0 → NaN), so fall back to its r→0 limit: payments with no compounding.
        let fv = r.isZero ? pmt * n : pmt * (pow(1 + r, n) - 1) / r

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
