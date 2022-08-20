//
//  FinancialData.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-06.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

var fileURL: URL {
    let directoryURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return directoryURL.appendingPathComponent("Financial Data", isDirectory: false).appendingPathExtension("json")
}

final class FinancialData: Codable, ObservableObject {
    
    static let newestFileVersion = 1

    let fileVersion: Int
    
    @Published var nonStockAssets: [Asset] {
       didSet {
           save()
       }
    }
    @Published var stocks: [Stock] {
       didSet {
           save()
       }
    }
    var assets: [Asset] {
        (nonStockAssets + stocks.map({ Asset(stock: $0) })).sorted(by: >)
    }
    
    @Published var debts: [Debt] {
        didSet {
            save()
        }
    }
    
    @Published var nonAssetIncome: [Income] {
       didSet {
           save()
       }
    }
    var income: [Income] {
        (nonAssetIncome + assets.map({ Income(asset: $0) })).filter({ $0.monthlyEarnings != 0 }).sorted(by: >)
    }
    var totalLiquidIncome: Double {
        income.filter({ $0.isLiquid }).reduce(0, { $0 + $1.monthlyEarnings })
    }
    var totalIncome: Double {
        income.reduce(0, { $0 + $1.monthlyEarnings })
    }
    
    @Published var nonDebtExpenses: [Expense] {
        didSet {
            save()
        }
    }
    var expenses: [Expense] {
        (nonDebtExpenses + debts.map({ Expense(debt: $0) })).filter({ $0.monthlyCost != 0 }).sorted(by: >)
    }
    var totalExpenses: Double {
        expenses.reduce(0, { $0 + $1.monthlyCost })
    }
    
    func netAssetsValue(at date: Date) -> Double {
        assets.reduce(0, { $0 + $1.currentValue(at: date) }) +
        debts.reduce(0, { $0 + $1.currentValue(at: date) })
    }

    func balance(at date: Date) -> Double {
        assets.filter({ $0.isLiquid }).reduce(0, { $0 + $1.currentValue(at: date) })
    }

    func netWorth(at date: Date) -> Double {
        assets.reduce(0, { $0 + $1.currentValue(at: date) }) - debts.reduce(0, { $0 + $1.currentValue(at: date) })
    }
    
    init(fileVersion: Int, nonStockAssets: [Asset], stocks: [Stock], debts: [Debt], nonAssetIncome: [Income], nonDebtExpenses: [Expense]) {
        self.fileVersion = fileVersion
        self.nonStockAssets = nonStockAssets
        self.stocks = stocks
        self.debts = debts
        self.nonAssetIncome = nonAssetIncome
        self.nonDebtExpenses = nonDebtExpenses
    }
    
    enum CodingKeys: String, CodingKey {
        case fileVersion, nonStockAssets, stocks, debts, nonAssetIncome, nonDebtExpenses
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fileVersion = (try? values.decode(Int.self, forKey: .fileVersion)) ?? Self.newestFileVersion
        nonStockAssets = (try? values.decode([Asset].self, forKey: .nonStockAssets)) ?? []
        stocks = try values.decode([Stock].self, forKey: .stocks)
        debts = try values.decode([Debt].self, forKey: .debts)
        nonAssetIncome = try values.decode([Income].self, forKey: .nonAssetIncome)
        nonDebtExpenses = try values.decode([Expense].self, forKey: .nonDebtExpenses)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileVersion, forKey: .fileVersion)
        try container.encode(nonStockAssets, forKey: .nonStockAssets)
        try container.encode(stocks, forKey: .stocks)
        try container.encode(debts, forKey: .debts)
        try container.encode(nonAssetIncome, forKey: .nonAssetIncome)
        try container.encode(nonDebtExpenses, forKey: .nonDebtExpenses)
    }
    
    func save() {
        do {
            let encoded = try JSONEncoder().encode(self)
            try encoded.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save")
        }
    }
    
}
