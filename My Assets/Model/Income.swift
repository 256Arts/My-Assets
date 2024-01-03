//
//  Income.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftData

@Model
class Income: Comparable, Hashable {
    
    static func < (lhs: Income, rhs: Income) -> Bool {
        lhs.monthlyEarnings ?? 0 < rhs.monthlyEarnings ?? 0
    }
    
    var name: String?
    var symbol: Symbol?
    var colorHex: String?
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorHex ?? "") + String(monthlyEarnings ?? 0)
    }
    var isLiquid: Bool?
    var monthlyEarnings: Double?
    var isPassive: Bool?
    let fromAsset: Bool?
    
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
    
}
