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
final class Debt: Hashable, Comparable {
    
    enum DebtError: Error {
        case missingName
    }
    
    static func < (lhs: Debt, rhs: Debt) -> Bool {
        lhs.currentValue < rhs.currentValue
    }
    
    var name: String?
    var symbol: Symbol?
    var colorName: ColorName?
    var annualInterestFraction: Double?
    var paymentAmount: Double?
    var paymentFrequency: TransactionFrequency?
    private var prevValue: Double?
    private var prevDate: Date?
    
    // MARK: Relationships
    
    var asset: Asset?
    var expense: Expense?
    
    // MARK: Computed Properties
    
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorName?.rawValue ?? "") + String(annualInterestFraction ?? 0)
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
    var paymentInterest: Double {
        guard let annualInterestFraction else { return .nan }
        
        return currentValue * annualInterestFraction / (12.0 * (paymentFrequency?.timesPerMonth ?? 1))
    }
    var monthsToPayOff: Double {
        guard let annualInterestFraction, let paymentAmount else { return .nan }
        
        guard 0 < paymentAmount else {
            return .infinity
        }
        
        let monthlyPayment = paymentAmount * (paymentFrequency?.timesPerMonth ?? 1)
        
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
    
    // MARK: Init
    
    init(name: String = "", symbol: Symbol = .defaultSymbol, value: Double = 0) {
        self.name = name
        self.symbol = symbol
        self.colorName = .gray
        self.annualInterestFraction = 0
        self.paymentAmount = 0
        self.paymentFrequency = .monthly
        self.prevValue = value
        self.prevDate = Date()
    }
    
    func currentValue(at date: Date) -> Double {
        guard let prevDate, let prevValue, let annualInterestFraction, let paymentAmount else { return .nan }
        
        let monthsSinceDate = date.timeIntervalSince(prevDate) / TimeInterval.month
        let monthlyPayment = paymentAmount * (paymentFrequency?.timesPerMonth ?? 1)
        
        guard !annualInterestFraction.isZero else {
            return prevValue - (monthsSinceDate * monthlyPayment)
        }
        
        let i = annualInterestFraction / 12
        let value = prevValue * pow(1 + i, monthsSinceDate) - (monthlyPayment / i) * (pow(1 + i, monthsSinceDate) - 1)
        return max(0, value)
    }
    
    func generateExpense(startDate: Date? = nil) throws {
        guard let name, let paymentFrequency else { throw DebtError.missingName }
        
        let expense = Expense(name: name, symbol: symbol ?? .defaultSymbol, category: .variable, baseAmount: 0)
        expense.colorName = colorName
        expense.startDate = startDate
        expense.frequency = paymentFrequency
        expense.fromDebt = self
        
        let interestExpense = Expense(name: "Interest", symbol: symbol ?? .defaultSymbol, category: .fixed, baseAmount: paymentInterest)
        interestExpense.startDate = startDate
        interestExpense.frequency = paymentFrequency
        
        let principalExpense = Expense(name: "Principal", symbol: symbol ?? .defaultSymbol, category: .savings, baseAmount: (paymentAmount ?? paymentInterest) - paymentInterest)
        principalExpense.startDate = startDate
        principalExpense.frequency = paymentFrequency
        
        expense.children = [ interestExpense, principalExpense ]
    }
    
}
