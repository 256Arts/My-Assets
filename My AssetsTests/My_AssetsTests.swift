//
//  My_AssetsTests.swift
//  My AssetsTests
//
//  Created by 256 Arts Developer on 2022-05-12.
//  Copyright © 2022 256 Arts Developer. All rights reserved.
//

import Foundation
import Testing
@testable import My_Assets

@Test
func testAsset() {
    var asset = Asset()
    asset.currentValue = 1000
    asset.annualInterestFraction = 0.12
    
    #expect(asset.currentValue.rounded() == 1000)
    // Default compoundFrequency is .none (compounds once per year): 1000 × 1.12 = 1120.
    #expect(asset.currentValue(at: .init(timeIntervalSinceNow: .year)).rounded() == 1120)
    #expect(asset.monthlyEarnings.rounded() == 10)
}

@Test
func testDebt() {
    var debt = Debt()
    debt.currentValue = 1200
    debt.annualInterestFraction = 0.12
    debt.paymentAmount = 100
    
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
    debt.paymentAmount = 25
    
    #expect(debt.currentValue.rounded() == 1000)
    #expect(debt.currentValue(at: .init(timeIntervalSinceNow: .month)).rounded() == 977)
    #expect(debt.currentValue(at: .init(timeIntervalSinceNow: .year)).rounded() == 717)
    #expect(debt.currentValue(at: .init(timeIntervalSinceNow: .year * 10)).rounded() == 0)
}

@Test
func testLiveOffTime() {
    let insights = InsightsGenerator(data: FinancialData(nonStockAssets: [Asset(value: 1_000)], stocks: [], debts: [], income: [], expenses: [Expense(baseAmount: 100)]))
    
    #expect(insights.liveOffMonths == 10)
}

@Test
func testAvgAnnualNetWorthInterest() {
    // Asset earns 10% on $2,000 (+$200/yr); debt accrues 5% on $1,000 (−$50/yr).
    // Weighted average over a $1,000 natural net worth = ($200 − $50) / $1,000 = 15%.
    // Regression guard: debt interest must be weighted by the debt's value, not used raw.
    let asset = Asset(value: 2_000, annualInterestFraction: 0.10)
    let debt = Debt(value: 1_000)
    debt.annualInterestFraction = 0.05
    let data = FinancialData(nonStockAssets: [asset], stocks: [], debts: [debt], income: [], expenses: [])

    #expect((data.avgAnnualNetWorthInterest * 100).rounded() == 15)
}

@Test
func testWorldStats() {
    // Query at the 2023 base year so no inflation projection is applied and the raw reference data is returned.
    let dataYear = Calendar.current.date(from: DateComponents(year: 2023))!
    let worldStats = WorldFinanceStats.usHouseholdNetWorthPercentiles(at: dataYear)

    #expect(worldStats[0] == .init(percentile: 0.01, money: -76_000))
    #expect(worldStats[5] == .init(percentile: 0.50, money: 192_000))
    #expect(worldStats[10] == .init(percentile: 0.99, money: 13_600_000))
}

@Test
func testNetWorthPercentile() {
    let insights = InsightsGenerator(data: FinancialData(nonStockAssets: [], stocks: [], debts: [], income: [], expenses: []))
    // Evaluate against the 2023 base-year brackets (no inflation projection); values picked at bracket boundaries.
    let dataYear = Calendar.current.date(from: DateComponents(year: 2023))!
    let usa = Locale(identifier: "en_US")

    #expect(((insights.netWorthPercentile(householdNetWorth: -1_000_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 0)
    #expect(((insights.netWorthPercentile(householdNetWorth: -76_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 1)
    #expect(((insights.netWorthPercentile(householdNetWorth: 400, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 10)
    #expect(((insights.netWorthPercentile(householdNetWorth: 192_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 50)
    #expect(((insights.netWorthPercentile(householdNetWorth: 252_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 55)
    #expect(((insights.netWorthPercentile(householdNetWorth: 13_600_000, at: dataYear, locale: usa) ?? 0) * 100).rounded() == 99)
}
