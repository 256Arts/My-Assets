//
//  Debt.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2021-12-29.
//  Copyright © 2021 256 Arts Developer. All rights reserved.
//

import Foundation
import SwiftData

@Model
class Debt: Hashable, Comparable {
    
    static func < (lhs: Debt, rhs: Debt) -> Bool {
        lhs.currentValue < rhs.currentValue
    }
    
    var name: String?
    var symbol: Symbol?
    var colorName: ColorName?
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorName?.rawValue ?? "") + String(annualInterestFraction ?? 0)
    }
    var annualInterestFraction: Double?
    var minimumMonthlyPayment: Double?
    var monthlyPayment: Double?
    
    var asset: Asset?
    
    var currentValue: Double {
        get {
            currentValue(at: .now)
        }
        set {
            prevValue = newValue
            prevDate = Date()
        }
    }
    
    var monthsToPayOff: Double {
        guard let annualInterestFraction, let monthlyPayment else { return .nan }
        
        guard !monthlyPayment.isZero else {
            return .infinity
        }
        
        guard !annualInterestFraction.isZero else {
            return currentValue / monthlyPayment
        }
        
        /* Using formulas:
         - Compound interest
         - Future value of a series
         Note: We get the formula below by solving for t.
        */
        let a = 0.0 // Future value
        let p = currentValue // Principal value
        let r = annualInterestFraction // Rate
        let n = 12.0 // Compounds per time unit
        let m = -monthlyPayment // Monthly payment
        let t = log((a * r + n * m) / (p * r + n * m)) / (n * log(1 + r / n))
        
        return t * 12
    }
    var monthsToPayOffString: String? {
        guard monthsToPayOff.isFinite, !monthsToPayOff.isNaN else { return nil }
        let time = DateComponents(day: Int(monthsToPayOff * 30))
        return timeRemainingFormatter.string(from: time)
    }
    
    private var prevValue: Double?
    private var prevDate: Date?
    
    init(name: String = "", symbol: Symbol = .defaultSymbol, value: Double = 0) {
        self.name = name
        self.symbol = symbol
        self.colorName = .gray
        self.annualInterestFraction = 0
        self.monthlyPayment = 0
        self.prevValue = value
        self.prevDate = Date()
    }
    
    func currentValue(at date: Date) -> Double {
        guard let prevDate, let prevValue, let annualInterestFraction, let monthlyPayment else { return .nan }
        
        let monthsSinceDate = date.timeIntervalSince(prevDate) / TimeInterval.month
        
        guard !annualInterestFraction.isZero else {
            return prevValue - (monthsSinceDate * monthlyPayment)
        }
        
        let i = annualInterestFraction / 12
        let value = prevValue * pow(1 + i, monthsSinceDate) - (monthlyPayment / i) * (pow(1 + i, monthsSinceDate) - 1)
        return max(0, value)
    }
    
}
