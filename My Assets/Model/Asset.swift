//
//  Models.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-06.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Asset: Comparable {
    
    enum CompoundFrequency: String, CaseIterable, Identifiable, Codable {
        case yearly
        case monthly
        case biweekly
        case none
        
        var id: Self { self }
        var timeInterval: TimeInterval {
            switch self {
            case .monthly:
                return .month
            case .biweekly:
                return .year / 26
            case .yearly, .none:
                return .year
            }
        }
        var periodsPerYear: Double {
            TimeInterval.year / timeInterval
        }
    }
    
    enum AssetError: Error {
        case missingName, noIncome
    }
    
    static func < (lhs: Asset, rhs: Asset) -> Bool {
        lhs.currentValue < rhs.currentValue
    }
    
    var name: String?
    var symbol: Symbol?
    var colorName: ColorName?
    var isLiquid: Bool?
    var compoundFrequency: CompoundFrequency?
    var annualInterestFraction: Double?
    private var prevValue: Double?
    private var prevDate: Date?
    
    // MARK: Relationships
    
    @Relationship(deleteRule: .cascade, inverse: \Income.fromAsset)
    var income: Income?
    
    @Relationship(deleteRule: .nullify, inverse: \Debt.asset)
    var loans: [Debt]?
    
    @Relationship(deleteRule: .cascade, inverse: \UpcomingSpend.asset)
    var upcomingSpends: [UpcomingSpend]?
    
    // MARK: Computed Properties
    
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorName?.rawValue ?? "") + (compoundFrequency?.rawValue ?? "")
    }
    var effectiveAnnualInterestFraction: Double {
        guard let annualInterestFraction else { return .nan }
        
        if let compoundFrequency, compoundFrequency.timeInterval != .year {
            return pow(1 + (annualInterestFraction / compoundFrequency.periodsPerYear), compoundFrequency.periodsPerYear) - 1
        } else {
            return annualInterestFraction
        }
    }
    var currentValue: Double {
        get {
            currentValue(at: .now)
        }
        set {
            prevValue = newValue
            prevDate = Date()
        }
    }
    var monthlyEarnings: Double {
        (currentValue * pow(1 + effectiveAnnualInterestFraction/12, 1)) - currentValue
    }
    
    // MARK: Init
    
    init(name: String = "", symbol: Symbol = .defaultSymbol, value: Double = 0, annualInterestFraction: Double = 0) {
        self.name = name
        self.symbol = symbol
        self.colorName = .gray
        self.isLiquid = true
        self.compoundFrequency = Asset.CompoundFrequency.none
        self.annualInterestFraction = annualInterestFraction
        self.prevValue = value
        self.prevDate = Date()
    }
    
    init(stock: Stock) {
        name = stock.symbol
        symbol = Symbol.stocks
        colorName = .gray
        isLiquid = true
        compoundFrequency = Asset.CompoundFrequency.none
        annualInterestFraction = stock.annualInterestFraction ?? 0.0
        prevValue = stock.price ?? 0.00 * Double(stock.quantity ?? 1)
        prevDate = Date()
    }
    
    func currentValue(at date: Date) -> Double {
        guard let prevDate, let prevValue, let compoundFrequency, let annualInterestFraction else { return .nan }
        
        let periodsSinceDate = date.timeIntervalSince(prevDate) / compoundFrequency.timeInterval
        return prevValue * pow(1 + (annualInterestFraction / compoundFrequency.periodsPerYear), periodsSinceDate)
    }
    
    func generateIncome(frequency: TransactionFrequency? = nil, startDate: Date? = nil) throws {
        guard let name else { throw AssetError.missingName }
        guard 0 < monthlyEarnings else { throw AssetError.noIncome }
        
        let income = Income(name: name, symbol: symbol ?? .defaultSymbol, isLiquid: isLiquid ?? true, amount: monthlyEarnings, isPassive: true)
        income.colorName = colorName
        income.frequency = frequency
        income.startDate = startDate
        
        self.income = income
    }
    
}
