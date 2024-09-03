//
//  My_AssetsTests.swift
//  My AssetsTests
//
//  Created by 256 Arts Developer on 2022-05-12.
//  Copyright © 2022 256 Arts Developer. All rights reserved.
//

import Foundation
import Testing

@Test
func testAsset() {
    var asset = Asset()
    asset.currentValue = 1000
    asset.annualInterestFraction = 0.12
    
    #expect(asset.currentValue.rounded() == 1000)
    #expect(asset.currentValue(at: .init(timeIntervalSinceNow: .year)).rounded() == 1127)
    #expect(asset.monthlyEarnings.rounded() == 10)
}

@Test
func testDebt() {
    var debt = Debt()
    debt.currentValue = 1200
    debt.annualInterestFraction = 0.12
    debt.monthlyPayment = 100
    
    #expect(debt.currentValue.rounded() == 1200)
    #expect(debt.currentValue(at: .init(timeIntervalSinceNow: .month)).rounded() == 1112)
    #expect(debt.currentValue(at: .init(timeIntervalSinceNow: .year)).rounded() == 84)
    #expect(debt.currentValue(at: .init(timeIntervalSinceNow: .year * 10)).rounded() == 0)
}

@Test
func testDebt2() {
    var debt = Debt()
    debt.currentValue = 1000
    debt.annualInterestFraction = 0.02
    debt.monthlyPayment = 25
    
    #expect(debt.currentValue.rounded() == 1000)
    #expect(debt.currentValue(at: .init(timeIntervalSinceNow: .month)).rounded() == 977)
    #expect(debt.currentValue(at: .init(timeIntervalSinceNow: .year)).rounded() == 717)
    #expect(debt.currentValue(at: .init(timeIntervalSinceNow: .year * 10)).rounded() == 0)
}

@Test
func testWorldStats() {
    let dataYear = Calendar.current.date(from: DateComponents(year: 2020))!
    let worldStats = WorldFinanceStats.usHouseholdNetWorthPercentiles(at: dataYear)
    
    #expect(worldStats[0] == .init(percentile: 0.01, money: -100_000))
    #expect(worldStats[5] == .init(percentile: 0.50, money: 120_000))
    #expect(worldStats[10] == .init(percentile: 0.99, money: 11_100_000))
}

@Test
func testNetWorthPercentile() {
    let insights = InsightsGenerator(data: FinancialData(nonStockAssets: [], stocks: [], debts: [], nonAssetIncome: [], expenses: []))
    let dataYear = Calendar.current.date(from: DateComponents(year: 2020))!
    let usa = Locale(identifier: "en_US")
    
    #expect(((insights.netWorthPercentile(householdNetWorth: -1_000_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 0)
    #expect(((insights.netWorthPercentile(householdNetWorth: -100_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 1)
    #expect(((insights.netWorthPercentile(householdNetWorth: -50_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 6)
    #expect(((insights.netWorthPercentile(householdNetWorth: -500, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 10)
    #expect(((insights.netWorthPercentile(householdNetWorth: 1000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 12)
    #expect(((insights.netWorthPercentile(householdNetWorth: 120_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 50)
    #expect(((insights.netWorthPercentile(householdNetWorth: 160_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 55)
    #expect(((insights.netWorthPercentile(householdNetWorth: 12_000_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 99)
}
