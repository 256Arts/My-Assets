//
//  InsightsGenerator.swift
//  My Assets
//
//  Created by Jayden Irwin on 2022-04-09.
//  Copyright © 2022 Jayden Irwin. All rights reserved.
//

import SwiftUI

final class InsightsGenerator {
    
    init(data: FinancialData) {
        self.data = data
    }
    
    let data: FinancialData
    
    var avgAnnualAssetsInterest: Double {
        // Uses weighted average
        let totalAssets = data.assets.filter({ $0.isLiquid }).reduce(0.0, { $0 + $1.currentValue }) // Excludes debts
        let avgAnnualAssetInterest = data.assets.filter({ $0.isLiquid }).reduce(0.0, { $0 + $1.effectiveAnnualInterestFraction * ($1.currentValue / totalAssets) })
        let avgAnnualDebtInterest = data.debts.reduce(0.0, { $0 + $1.annualInterestFraction * ($1.currentValue / totalAssets) })
        return avgAnnualAssetInterest - avgAnnualDebtInterest
    }
    var avgAnnualBalanceInterest: Double {
        let interest = (data.balance(at: Date(timeIntervalSinceNow: .year)) / data.balance(at: .now)) - 1.0
        return interest.isFinite ? interest : 0
    }
    var avgAnnualNetWorthInterest: Double {
        let interest = (data.netWorth(at: Date(timeIntervalSinceNow: .year)) / data.netWorth(at: .now)) - 1.0
        return interest.isFinite ? interest : 0
    }
    var liveOffMonths: Double {
        guard 0 < data.balance(at: .now) else { return 0.0 }
        let passiveIncome = data.income.filter { $0.isPassive }
        let totalPassiveIncome = passiveIncome.reduce(0.0, { $0 + $1.monthlyEarnings })
        guard totalPassiveIncome < data.totalExpenses else { return .infinity }
        
        // Static = Same amount every month
        let totalStaticExpenses = data.expenses.filter { !$0.fromDebt }.reduce(0.0, { $0 + $1.monthlyCost })
        let totalStaticPassiveIncome = passiveIncome.filter { !$0.fromAsset }.reduce(0.0, { $0 + $1.monthlyEarnings })
        let staticMonthlyDrain = totalStaticExpenses - totalStaticPassiveIncome
        
        // Dynamic = Different amount every month based on interest percentages
        /* Using formulas:
         - Compound interest
         - Future value of a series
         Note: We get the formula below by solving for t.
        */
        let a = 0.0 // Future value
        let p = data.balance(at: .now) // Principal value
        let r = avgAnnualBalanceInterest // Rate
        let n = 12.0 // Compounds per time unit
        let m = -staticMonthlyDrain // Monthly payment
        let t = log((a * r + n * m) / (p * r + n * m)) / (n * log(1 + r / n))
        
        return t * 12
    }
    var retirementDate: Date? {
        let birthdayTimeSinceReference = UserDefaults.standard.double(forKey: UserDefaults.Key.birthday)
        
        guard birthdayTimeSinceReference != 0 else { return nil }
        
        let birthday = Date(timeIntervalSinceReferenceDate: birthdayTimeSinceReference)
        return birthday + (65 * .year)
    }
    var retirementBalance: Double? {
        guard let retirementDate = retirementDate, 0 < retirementDate.timeIntervalSinceNow else { return nil }
        
        return data.balance(at: retirementDate)
    }
    
    func netWorthPercentile() -> Double? {
        let userType = UserType(rawValue: UserDefaults.standard.string(forKey: UserDefaults.Key.userType) ?? "") ?? .individual
        let householdNetWorth = data.netWorth(at: .now) * (userType == .individual ? 2 : 1)
        return netWorthPercentile(householdNetWorth: householdNetWorth, at: .now, locale: .current)
    }
    func netWorthPercentile(householdNetWorth: Double, at date: Date, locale: Locale) -> Double? {
        guard let conversionRate = WorldFinanceStats.shared.conversionRates[locale.currencyCode ?? ""] else { return nil }
        
        let myNetWorth = householdNetWorth * conversionRate
        var myBracket = WorldFinanceStats.Bracket(percentile: 0.0, money: myNetWorth)
        
        for bracket in WorldFinanceStats.shared.usHouseholdNetWorthPercentiles(at: date) {
            if myNetWorth < bracket.money {
                let fractionToBracket = (myNetWorth - myBracket.money) / (bracket.money - myBracket.money)
                let percentile = myBracket.percentile + (fractionToBracket * (bracket.percentile - myBracket.percentile))
                myBracket = .init(percentile: percentile, money: myNetWorth)
                break
            } else {
                myBracket = bracket
            }
        }
        return myBracket.percentile
    }
    
    // Strings
    var avgAnnualAssetsInterestString: String {
        percentFormatter.string(from: NSNumber(value: avgAnnualAssetsInterest))!
    }
    var avgAnnualBalanceInterestString: String {
        percentFormatter.string(from: NSNumber(value: avgAnnualBalanceInterest))!
    }
    var avgAnnualNetWorthInterestString: String {
        percentFormatter.string(from: NSNumber(value: avgAnnualNetWorthInterest))!
    }
    var balanceIn5YearsString: String {
        currencyFormatter.string(from: NSNumber(value: data.balance(at: .now + 5 * TimeInterval.year)))!
    }
    var netWorthIn5YearsString: String {
        currencyFormatter.string(from: NSNumber(value: data.netWorth(at: .now + 5 * TimeInterval.year)))!
    }
    var retirementBalanceString: String? {
        guard let retirementBalance = retirementBalance else { return nil }

        return currencyFormatter.string(from: NSNumber(value: retirementBalance))!
    }
    var adjustedRetirementBalanceString: String? {
        guard let retirementBalance = retirementBalance, let retirementDate = retirementDate else { return nil }

        return currencyFormatter.string(from: NSNumber(value: WorldFinanceStats.shared.adjustForInflation(value: retirementBalance, in: retirementDate)))!
    }
    var liveOffTimeString: String {
        guard !liveOffMonths.isInfinite, !liveOffMonths.isNaN else { return "forever" }
        let liveOffTime = DateComponents(day: Int(liveOffMonths * 30))
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.day, .month, .year]
        return formatter.string(from: liveOffTime) ?? "unknown"
    }
    var requiredBalanceToLiveOffString: String? {
        guard 0 < avgAnnualBalanceInterest else { return nil }
        
        let totalStaticExpenses = data.expenses.filter { !$0.fromDebt }.reduce(0.0, { $0 + $1.monthlyCost })
        let totalStaticPassiveIncome = data.income.filter { $0.isPassive && !$0.fromAsset }.reduce(0.0, { $0 + $1.monthlyEarnings })
        let staticMonthlyDrain = totalStaticExpenses - totalStaticPassiveIncome
        
        let requiredNewAssets = staticMonthlyDrain / (avgAnnualBalanceInterest / 12)
        return currencyFormatter.string(from: NSNumber(value: data.balance(at: .now) + requiredNewAssets))!
    }
    var netWorthPercentileString: String? {
        guard let netWorthPercentile = netWorthPercentile() else { return nil }
        
        if netWorthPercentile < 0.5 {
            return "bottom \(percentFormatter.string(from: NSNumber(value: netWorthPercentile))!)"
        } else {
            return "top \(percentFormatter.string(from: NSNumber(value: 1 - netWorthPercentile))!)"
        }
    }
    
    func generate() -> [AttributedString] {
        var insights: [AttributedString] = []
        if 0 < liveOffMonths {
            insights.append(try! AttributedString(markdown: "You could live off your \(0 < data.income.filter { $0.isPassive && !$0.fromAsset }.count ? "passive income" : "assets") for **\(liveOffTimeString)**."))
        }
        if liveOffTimeString != "forever", let requiredBalanceToLiveOffString = requiredBalanceToLiveOffString {
            insights.append(try! AttributedString(markdown: "You need **\(requiredBalanceToLiveOffString)** to live off of your passive income forever."))
        }
        if let retirementBalanceString = retirementBalanceString, let adjustedRetirementBalanceString = adjustedRetirementBalanceString {
//            insights.append(try! AttributedString(markdown: "At retirement, your balance could be **\(retirementBalanceString)**. (**\(adjustedRetirementBalanceString)** adjusted for inflation.)"))
        }
        return insights
    }
    
}

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
