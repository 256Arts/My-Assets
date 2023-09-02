//
//  Expense.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftData

@Model
class Expense: Hashable, Comparable {
    
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Expense, rhs: Expense) -> Bool {
        lhs.monthlyCost < rhs.monthlyCost
    }
    
    var name: String?
    var symbol: Symbol?
    var colorHex: String?
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorHex ?? "") + String(baseMonthlyCost ?? 0)
    }
    var baseMonthlyCost: Double?
    var monthlyCost: Double {
        (baseMonthlyCost ?? .nan) + (children ?? []).reduce(0, { $0 + $1.baseMonthlyCost! })
    }
    let fromDebt: Bool?
    var parent: Expense?
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.parent)
    var children: [Expense]?
    
    init(name: String, symbol: Symbol, monthlyCost: Double) {
        self.name = name
        self.symbol = symbol
        self.colorHex = "000000"
        self.baseMonthlyCost = monthlyCost
        self.fromDebt = false
        self.children = []
    }
    
    init(debt: Debt) {
        name = debt.name
        symbol = debt.symbol
        colorHex = debt.colorHex
        baseMonthlyCost = debt.monthlyPayment
        fromDebt = true
        children = []
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
