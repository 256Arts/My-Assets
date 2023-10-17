//
//  My_AssetsTests.swift
//  My AssetsTests
//
//  Created by Jayden Irwin on 2022-05-12.
//  Copyright © 2022 Jayden Irwin. All rights reserved.
//

import XCTest

class My_AssetsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAsset() {
        var asset = Asset()
        asset.currentValue = 1000
        asset.annualInterestFraction = 0.12
        
        XCTAssertEqual(asset.currentValue.rounded(), 1000)
        XCTAssertEqual(asset.currentValue(at: .init(timeIntervalSinceNow: .year)).rounded(), 1127)
        XCTAssertEqual(asset.monthlyEarnings.rounded(), 10)
    }
    
    func testDebt() {
        var debt = Debt()
        debt.currentValue = 1200
        debt.annualInterestFraction = 0.12
        debt.monthlyPayment = 100
        
        XCTAssertEqual(debt.currentValue.rounded(), 1200)
        XCTAssertEqual(debt.currentValue(at: .init(timeIntervalSinceNow: .month)).rounded(), 1112)
        XCTAssertEqual(debt.currentValue(at: .init(timeIntervalSinceNow: .year)).rounded(), 84)
        XCTAssertEqual(debt.currentValue(at: .init(timeIntervalSinceNow: .year * 10)).rounded(), 0)
    }
    
    func testDebt2() {
        var debt = Debt()
        debt.currentValue = 1000
        debt.annualInterestFraction = 0.02
        debt.monthlyPayment = 25
        
        XCTAssertEqual(debt.currentValue.rounded(), 1000)
        XCTAssertEqual(debt.currentValue(at: .init(timeIntervalSinceNow: .month)).rounded(), 977)
        XCTAssertEqual(debt.currentValue(at: .init(timeIntervalSinceNow: .year)).rounded(), 717)
        XCTAssertEqual(debt.currentValue(at: .init(timeIntervalSinceNow: .year * 10)).rounded(), 0)
    }
    
    func testWorldStats() {
        let dataYear = Calendar.current.date(from: DateComponents(year: 2020))!
        let worldStats = WorldFinanceStats.shared.usHouseholdNetWorthPercentiles(at: dataYear)
        
        XCTAssertEqual(worldStats[0], .init(percentile: 0.01, money: -100_000))
        XCTAssertEqual(worldStats[5], .init(percentile: 0.50, money: 120_000))
        XCTAssertEqual(worldStats[10], .init(percentile: 0.99, money: 11_100_000))
    }
    
    func testNetWorthPercentile() {
        let insights = InsightsGenerator(data: FinancialData(nonStockAssets: [], stocks: [], debts: [], nonAssetIncome: [], nonDebtExpenses: []))
        let dataYear = Calendar.current.date(from: DateComponents(year: 2020))!
        let usa = Locale(identifier: "en_US")
        
        XCTAssertEqual(((insights.netWorthPercentile(householdNetWorth: -1_000_000, at: dataYear, locale: usa) ?? 0) * 100).rounded(), 0)
        XCTAssertEqual(((insights.netWorthPercentile(householdNetWorth: -100_000, at: dataYear, locale: usa) ?? 0) * 100).rounded(), 1)
        XCTAssertEqual(((insights.netWorthPercentile(householdNetWorth: -50_000, at: dataYear, locale: usa) ?? 0) * 100).rounded(), 6)
        XCTAssertEqual(((insights.netWorthPercentile(householdNetWorth: -500, at: dataYear, locale: usa) ?? 0) * 100).rounded(), 10)
        XCTAssertEqual(((insights.netWorthPercentile(householdNetWorth: 1000, at: dataYear, locale: usa) ?? 0) * 100).rounded(), 12)
        XCTAssertEqual(((insights.netWorthPercentile(householdNetWorth: 120_000, at: dataYear, locale: usa) ?? 0) * 100).rounded(), 50)
        XCTAssertEqual(((insights.netWorthPercentile(householdNetWorth: 160_000, at: dataYear, locale: usa) ?? 0) * 100).rounded(), 55)
        XCTAssertEqual(((insights.netWorthPercentile(householdNetWorth: 12_000_000, at: dataYear, locale: usa) ?? 0) * 100).rounded(), 99)
    }

}
