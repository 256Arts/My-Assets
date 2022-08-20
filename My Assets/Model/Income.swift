//
//  Income.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import Foundation

struct Income: Comparable, Identifiable, Codable {
    
    static func < (lhs: Income, rhs: Income) -> Bool {
        lhs.monthlyEarnings < rhs.monthlyEarnings
    }
    
    var name: String
    var symbol: Symbol
    var colorHex: String
    var id: String {
        name
    }
    var isLiquid: Bool
    var monthlyEarnings: Double
    var isPassive: Bool
    let fromAsset: Bool
    
    init(name: String, symbol: Symbol, isLiquid: Bool, monthlyEarnings: Double, isPassive: Bool) {
        self.name = name
        self.symbol = symbol
        self.colorHex = "000000"
        self.isLiquid = true
        self.monthlyEarnings = monthlyEarnings
        self.isPassive = isPassive
        self.fromAsset = false
    }
    
    init(asset: Asset) {
        name = asset.name
        symbol = asset.symbol
        colorHex = asset.colorHex
        isLiquid = asset.isLiquid
        monthlyEarnings = asset.monthlyEarnings
        isPassive = true
        fromAsset = true
    }
    
    enum CodingKeys: String, CodingKey {
        case name, symbol, colorHex, isLiquid, monthlyEarnings, isPassive
    }
    enum CodingError: Error {
        case isFromAsset
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let symbolName = try values.decode(String.self, forKey: .symbol)
        symbol = .init(rawValue: symbolName) ?? .init(rawValue: Symbol.defaultSymbol.rawValue)!
        colorHex = try values.decode(String.self, forKey: .colorHex)
        isLiquid = (try? values.decode(Bool.self, forKey: .isLiquid)) ?? true
        monthlyEarnings = try values.decode(Double.self, forKey: .monthlyEarnings)
        isPassive = try values.decode(Bool.self, forKey: .isPassive)
        fromAsset = false
    }
    
    func encode(to encoder: Encoder) throws {
        guard !fromAsset else { throw CodingError.isFromAsset }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(symbol.rawValue, forKey: .symbol)
        try container.encode(colorHex, forKey: .colorHex)
        try container.encode(isLiquid, forKey: .isLiquid)
        try container.encode(monthlyEarnings, forKey: .monthlyEarnings)
        try container.encode(isPassive, forKey: .isPassive)
    }
    
}
