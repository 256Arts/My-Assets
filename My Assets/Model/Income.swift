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
    var monthlyEarnings: Double?
    var isPassive: Bool?
    var transactionDateStart: Date?
    var transactionFrequency: TransactionFrequency?
    
    // MARK: Relationships
    
    @Transient
    var fromAsset: Bool = false
    
    // MARK: Computed Properties
    
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorName?.rawValue ?? "") + String(monthlyEarnings ?? 0)
    }
    var transactionAmount: Double? {
        guard let monthlyEarnings, let transactionFrequency else { return nil }
        
        return monthlyEarnings / transactionFrequency.timesPerMonth
    }
    var nextTransactionDate: Date? {
        guard let transactionFrequency, let transactionDateStart else { return nil }
        
        let calendar = Calendar.autoupdatingCurrent
        var nextDate = transactionDateStart
        while nextDate.timeIntervalSince(calendar.startOfDay(for: .now)) < 0 {
            nextDate = calendar.date(byAdding: transactionFrequency.calendarValues.0, value: transactionFrequency.calendarValues.1, to: nextDate)!
        }
        return nextDate
    }
    
    // MARK: Init
    
    init(name: String, symbol: Symbol, isLiquid: Bool, monthlyEarnings: Double, isPassive: Bool) {
        self.name = name
        self.symbol = symbol
        self.colorName = .gray
        self.isLiquid = true
        self.monthlyEarnings = monthlyEarnings
        self.isPassive = isPassive
        self.fromAsset = false
    }
    
    init(asset: Asset) {
        name = asset.name
        symbol = asset.symbol
        colorName = asset.colorName
        isLiquid = asset.isLiquid
        monthlyEarnings = asset.monthlyEarnings
        isPassive = true
        fromAsset = true
    }
    
}
