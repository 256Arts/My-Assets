//
//  Debt.swift
//  My Assets
//
//  Created by Jayden Irwin on 2021-12-29.
//  Copyright © 2021 Jayden Irwin. All rights reserved.
//

import Foundation

struct Debt: Comparable, Identifiable, Codable {
    
    static func < (lhs: Debt, rhs: Debt) -> Bool {
        lhs.currentValue < rhs.currentValue
    }
    
    var name: String
    var symbol: Symbol
    var colorHex: String
    var id: String {
        name
    }
    var annualInterestFraction: Double
    var monthlyPayment: Double
    
    var currentValue: Double {
        get {
            currentValue(at: .now)
        }
        set {
            prevValue = newValue
            prevDate = Date()
        }
    }
    
    private var prevValue: Double
    private var prevDate: Date
    
    init() {
        self.name = ""
        self.symbol = Symbol.defaultSymbol
        self.colorHex = "000000"
        self.annualInterestFraction = 0
        self.monthlyPayment = 0
        self.prevValue = 0
        self.prevDate = Date()
    }
    
    func currentValue(at date: Date) -> Double {
        let monthsSinceDate = date.timeIntervalSince(prevDate) / TimeInterval.month
        let i = annualInterestFraction / 12
        let value = prevValue * pow(1 + i, monthsSinceDate) - (monthlyPayment / i) * (pow(1 + i, monthsSinceDate) - 1)
        return max(0, value)
    }
    
}
