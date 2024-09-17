//
//  Expense.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI
import SwiftData

@Model
final class Expense: Schedulable, Hashable, Comparable {
    
    enum Category: String, CaseIterable, Identifiable, Codable {
        case fixed, variable, intermittent, discretionary, savings
        
        var id: Self { self }
        var name: String {
            switch self {
            case .fixed:
                "Fixed"
            case .variable:
                "Variable"
            case .intermittent:
                "Intermittent"
            case .discretionary:
                "Discretionary"
            case .savings:
                "Savings"
            }
        }
        var icon: Image {
            switch self {
            case .fixed:
                Image(systemName: "lock")
            case .variable:
                Image(systemName: "bolt")
            case .intermittent:
                Image(systemName: "wrench.and.screwdriver")
            case .discretionary:
                Image(systemName: "bag")
            case .savings:
                Image(systemName: "building.columns")
            }
        }
        var color: Color {
            switch self {
            case .fixed:
                .gray
            case .variable:
                .yellow
            case .intermittent:
                .orange
            case .discretionary:
                .red
            case .savings:
                .green
            }
        }
    }
    
    var name: String?
    var symbol: Symbol?
    var colorName: ColorName?
    var category: Category?
    var baseAmount: Double?
    var startDate: Date?
    var frequency: TransactionFrequency?
    
    // MARK: Relationships
    
    @Relationship(deleteRule: .cascade, inverse: \Debt.expense)
    var fromDebt: Debt?
    
    var parent: Expense?
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.parent)
    var children: [Expense]?
    
    // MARK: Computed Properties
    
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorName?.rawValue ?? "") + String(baseAmount ?? 0)
    }
    var amount: Double? {
        guard let frequency else { return nil }
        
        return -monthlyCost() / frequency.timesPerMonth
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
    
    init(name: String = "", symbol: Symbol = .defaultSymbol, category: Category = .discretionary, baseAmount: Double, children: [Expense] = []) {
        self.name = name
        self.symbol = symbol
        self.colorName = .gray
        self.category = category
        self.baseAmount = baseAmount
        self.children = children
    }
    
    func monthlyCost(excludingSavings: Bool = false) -> Double {
        let baseMonthlyCost = (excludingSavings && category == .savings) ? 0.0 : (baseAmount ?? 0.0) * (frequency?.timesPerMonth ?? 1)
        
        return baseMonthlyCost + (children ?? []).reduce(0, { $0 + $1.monthlyCost(excludingSavings: excludingSavings) })
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Expense, rhs: Expense) -> Bool {
        lhs.monthlyCost() < rhs.monthlyCost()
    }
    
}
