//
//  Expense.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import Foundation

class Expense: ObservableObject, Hashable, Comparable, Identifiable, Codable {
    
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Expense, rhs: Expense) -> Bool {
        lhs.monthlyCost < rhs.monthlyCost
    }
    
    @Published var name: String
    @Published var symbol: Symbol
    @Published var colorHex: String
    var id: String {
        name + symbol.rawValue + colorHex + String(baseMonthlyCost)
    }
    @Published var baseMonthlyCost: Double
    var monthlyCost: Double {
        baseMonthlyCost + children.reduce(0, { $0 + $1.baseMonthlyCost })
    }
    let fromDebt: Bool
    @Published var children: [Expense]
    
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
    
    enum CodingKeys: String, CodingKey {
        case name, symbol, colorHex, monthlyCost, children
    }
    enum CodingError: Error {
        case isFromDebt
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let symbolName = try values.decode(String.self, forKey: .symbol)
        symbol = .init(rawValue: symbolName) ?? .init(rawValue: Symbol.defaultSymbol.rawValue)!
        colorHex = try values.decode(String.self, forKey: .colorHex)
        baseMonthlyCost = try values.decode(Double.self, forKey: .monthlyCost)
        fromDebt = false
        children = (try? values.decode([Expense].self, forKey: .children)) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        guard !fromDebt else { throw CodingError.isFromDebt }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(symbol.rawValue, forKey: .symbol)
        try container.encode(colorHex, forKey: .colorHex)
        try container.encode(baseMonthlyCost, forKey: .monthlyCost)
        try container.encode(children, forKey: .children)
    }
    
}
