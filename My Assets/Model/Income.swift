//
//  Income.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Income: Schedulable, Comparable, Hashable {
    
    static func < (lhs: Income, rhs: Income) -> Bool {
        lhs.monthlyEarnings ?? 0 < rhs.monthlyEarnings ?? 0
    }
    
    var name: String?
    var symbol: Symbol?
    var colorName: ColorName?
    var isLiquid: Bool?
    var amount: Double?
    var isPassive: Bool?
    var startDate: Date?
    var frequency: TransactionFrequency?
    
    // MARK: Relationships
    
    var fromAsset: Asset?
    
    // MARK: Computed Properties
    
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorName?.rawValue ?? "") + String(monthlyEarnings ?? 0)
    }
    var monthlyEarnings: Double? {
        guard let amount, let frequency else { return amount }
        
        return amount * frequency.timesPerMonth
    }
    var nextTransactionDate: Date? {
        guard let frequency, let startDate else { return nil }
        
        let calendar = Calendar.autoupdatingCurrent
        var nextDate = startDate
        while nextDate.timeIntervalSince(calendar.startOfDay(for: .now)) < 0 {
            nextDate = calendar.date(byAdding: frequency.calendarValues.0, value: frequency.calendarValues.1, to: nextDate)!
        }
        return nextDate
    }
    
    // MARK: Init
    
    init(name: String, symbol: Symbol, isLiquid: Bool, amount: Double, isPassive: Bool, startDate: Date? = nil) {
        self.name = name
        self.symbol = symbol
        self.colorName = .gray
        self.isLiquid = true
        self.amount = amount
        self.isPassive = isPassive
        self.startDate = startDate
        if startDate != nil {
            self.frequency = .monthly
        }
    }
    
}
