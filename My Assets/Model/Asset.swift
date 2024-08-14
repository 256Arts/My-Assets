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
    
    static func < (lhs: Asset, rhs: Asset) -> Bool {
        lhs.currentValue < rhs.currentValue
    }
    
    var name: String?
    var symbol: Symbol?
    var colorName: ColorName?
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorName?.rawValue ?? "") + (compoundFrequency?.rawValue ?? "")
    }
    var isLiquid: Bool?
    var compoundFrequency: CompoundFrequency?
    var annualInterestFraction: Double?
    
    @Relationship(deleteRule: .cascade, inverse: \Debt.asset)
    var loans: [Debt]?
    
    @Relationship(deleteRule: .cascade, inverse: \UpcomingSpend.asset)
    var upcomingSpends: [UpcomingSpend]?
    
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
    
    private var prevValue: Double?
    private var prevDate: Date?
    
    init(name: String = "", symbol: Symbol = .defaultSymbol, value: Double = 0) {
        self.name = name
        self.symbol = symbol
        self.colorName = .gray
        self.isLiquid = true
        self.compoundFrequency = Asset.CompoundFrequency.none
        self.annualInterestFraction = 0
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

    enum CodingKeys: String, CodingKey {
        case name, symbol, colorName, isLiquid, compoundFrequency, annualInterestFraction, prevValue, prevDate
    }

    // For legacy decode
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        symbol = try values.decode(Symbol.self, forKey: .symbol)
        colorName = try values.decode(ColorName.self, forKey: .colorName)
        isLiquid = (try? values.decode(Bool.self, forKey: .isLiquid)) ?? true
        compoundFrequency = (try? values.decode(CompoundFrequency.self, forKey: .compoundFrequency)) ?? Asset.CompoundFrequency.none
        annualInterestFraction = try values.decode(Double.self, forKey: .annualInterestFraction)
        prevValue = try values.decode(Double.self, forKey: .prevValue)
        prevDate = try values.decode(Date.self, forKey: .prevDate)
    }
    
    func currentValue(at date: Date) -> Double {
        guard let prevDate, let prevValue, let compoundFrequency, let annualInterestFraction else { return .nan }
        
        let periodsSinceDate = date.timeIntervalSince(prevDate) / compoundFrequency.timeInterval
        return prevValue * pow(1 + (annualInterestFraction / compoundFrequency.periodsPerYear), periodsSinceDate)
    }
    
}
