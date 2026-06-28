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
func testStockAssetValueUsesQuantity() {
    // A holding of 10 shares at $150 is worth $1,500 in net worth — not $150 (one share).
    // Regression guard for the `price ?? 0 * quantity` precedence bug, where `*` bound
    // tighter than `??` so a non-nil price ignored quantity entirely.
    let stock = Stock(symbol: "AAPL", quantity: 10)
    stock.price = 150
    let asset = Asset(stock: stock)

    #expect(asset.currentValue.rounded() == 1_500)
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
func testNetWorthProjectionWithZeroInterest() {
    // A $1,000 cash asset at 0% interest, plus $100/mo net income and no expenses.
    // With a zero weighted-average interest rate the annuity formula's `/r` term is
    // a 0/0 singularity; the projection must fall back to simple (uncompounded) growth
    // instead of producing NaN. After one year: $1,000 + $100 × 12 = $2,200.
    let asset = Asset(value: 1_000, annualInterestFraction: 0)
    let income = Income(name: "Salary", symbol: .banknote, isLiquid: true, amount: 100, isPassive: false)
    let data = FinancialData(nonStockAssets: [asset], stocks: [], debts: [], income: [income], expenses: [])

    #expect(data.avgAnnualNetWorthInterest.isZero)
    let projected = data.netWorth(at: .init(timeIntervalSinceNow: .year), type: .working)
    #expect(projected.isNaN == false)
    #expect(projected.rounded() == 2_200)
}

@Test
func testSavingsCompoundAtAssetYieldNotROE() {
    // $200k liquid assets @ 5%, $150k debt @ 0% with no payments (stays flat).
    // Net worth = $50k, so return on equity is amplified by leverage:
    //   net interest $10k / $50k net worth = 20% ROE.
    // But newly saved cash earns the asset yield, not ROE:
    //   $10k / $200k assets = 5%.
    let asset = Asset(value: 200_000, annualInterestFraction: 0.05)
    let debt = Debt(value: 150_000, paymentAmount: 0)
    debt.annualInterestFraction = 0
    let income = Income(name: "Salary", symbol: .banknote, isLiquid: true, amount: 2_000, isPassive: false)
    let data = FinancialData(nonStockAssets: [asset], stocks: [], debts: [debt], income: [income], expenses: [])

    #expect((data.avgAnnualNetWorthInterest * 100).rounded() == 20) // leveraged ROE (headline)
    #expect((data.avgAnnualSavingsInterest * 100).rounded() == 5)   // un-leveraged asset yield

    // One-year projection: assets 200k → 210k, debt flat at 150k, plus a $2,000/mo
    // savings annuity compounded at 5% (≈ $24,557). Net worth ≈ $84,557.
    // If savings wrongly compounded at the 20% ROE the annuity would be ≈ $26,326,
    // pushing net worth to ≈ $86,326 — the "YoY net is too high" bug.
    let projected = data.netWorth(at: .init(timeIntervalSinceNow: .year), type: .working)
    #expect(abs(projected - 84_557) < 2)
}

@Test
func testSavingsInterestBlendsAllAssets() {
    // Birds-eye savings yield weights across ALL assets, including illiquid ones:
    // liquid $200k @ 5% plus an illiquid home $100k @ 3%.
    //   (0.05 × 200k + 0.03 × 100k) / 300k = $13k / $300k ≈ 4.33%.
    // A liquid-only weighting would instead give 5%.
    let liquid = Asset(value: 200_000, annualInterestFraction: 0.05)
    let home = Asset(value: 100_000, annualInterestFraction: 0.03)
    home.isLiquid = false
    let data = FinancialData(nonStockAssets: [liquid, home], stocks: [], debts: [], income: [], expenses: [])

    #expect((data.avgAnnualSavingsInterest * 1_000).rounded() == 43) // 4.33%, not 5%
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
