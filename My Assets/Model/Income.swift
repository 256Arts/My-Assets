//
//  Income.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftData

@Model
final class Income: Comparable, Hashable {
    
    static func < (lhs: Income, rhs: Income) -> Bool {
        lhs.monthlyEarnings ?? 0 < rhs.monthlyEarnings ?? 0
    }
    
    var name: String?
    var symbol: Symbol?
    var colorName: ColorName?
    var id: String {
        (name ?? "") + (symbol?.rawValue ?? "") + (colorName?.rawValue ?? "") + String(monthlyEarnings ?? 0)
    }
    var isLiquid: Bool?
    var monthlyEarnings: Double?
    var isPassive: Bool?
    let fromAsset: Bool?
    
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
