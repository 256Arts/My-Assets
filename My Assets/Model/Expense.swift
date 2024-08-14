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
final class Expense: Hashable, Comparable {
    
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
    
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Expense, rhs: Expense) -> Bool {
        lhs.monthlyCost < rhs.monthlyCost
    }
    
    var name: String?
    var symbol: Symbol?
    var colorName: ColorName?
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorName?.rawValue ?? "") + String(baseMonthlyCost ?? 0)
    }
    var category: Category?
    var baseMonthlyCost: Double?
    var monthlyCost: Double {
        let children = self.children ?? []
        let baseMonthlyCost = self.baseMonthlyCost ?? 0.0
        guard !children.isEmpty else { return baseMonthlyCost }
        
        return baseMonthlyCost + children.reduce(0, { $0 + $1.monthlyCost })
    }
    let fromDebt: Bool?
    var parent: Expense?
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.parent)
    var children: [Expense]?
    
    init(name: String, symbol: Symbol, category: Category, monthlyCost: Double) {
        self.name = name
        self.symbol = symbol
        self.colorName = .gray
        self.category = category
        self.baseMonthlyCost = monthlyCost
        self.fromDebt = false
        self.children = []
    }
    
    init(debt: Debt, extraPaymentOnly: Bool = false) {
        name = debt.name
        symbol = debt.symbol
        colorName = debt.colorName
        fromDebt = true
        
        category = .fixed
        baseMonthlyCost = debt.monthlyPayment
        children = []
        
        /*
        if extraPaymentOnly {
            category = .savings
            baseMonthlyCost = (debt.monthlyPayment ?? 0) - (debt.minimumMonthlyPayment ?? 0)
            children = []
        } else {
            category = .fixed
            baseMonthlyCost = debt.minimumMonthlyPayment
            if debt.monthlyPayment == debt.minimumMonthlyPayment {
                children = []
            } else {
                children = [
                    Expense(debt: debt, extraPaymentOnly: true)
                ]
            }
        }
         */
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
