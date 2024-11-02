//
//  Secrets.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2024-08-14.
//  Copyright © 2024 256 Arts Developer. All rights reserved.
//

enum Secrets {
    
    static let alphaVantageKey = "MZ4NGAVYGGF4NACP"
    
}

#if DEBUG
import SwiftData

func restoreBackup(context: ModelContext) {
    let backupAssets = [
        Asset(name: "House", symbol: .house, value: 823_000, annualInterestFraction: 0.03),
        Asset(name: "Coinsquare", symbol: .bitcoin, value: 104_000, annualInterestFraction: 0.10),
        Asset(name: "Moomoo Stocks", symbol: .stocks, value: 40_000, annualInterestFraction: 0.10),
        Asset(name: "Generac Stock", symbol: .stocks, value: 31_000, annualInterestFraction: 0.03),
        Asset(name: "Bolt EV", symbol: .car, value: 30_000, annualInterestFraction: 0.00),
        Asset(name: "Coinbase", symbol: .bitcoin, value: 27_000, annualInterestFraction: 0.10),
        Asset(name: "Tangerine", symbol: .bank, value: 1_500, annualInterestFraction: 0.005),
        Asset(name: "BMO", symbol: .bank, value: 500, annualInterestFraction: 0.005)
    ]
    let backupDebts = [
        Debt(name: "Mortgage", symbol: .house, value: 573_000),
        Debt(name: "Car Loan", symbol: .car, value: 34_000)
    ]
    let backupIncome = [
        Income(name: "Work", symbol: .building, isLiquid: true, amount: 4_100, isPassive: false),
        Income(name: "Nick's Payment", symbol: .app, isLiquid: true, amount: 2_000, isPassive: false),
        Income(name: "App Sales", symbol: .app, isLiquid: true, amount: 50, isPassive: true),
        Income(name: "Bricklink", symbol: .shippingbox, isLiquid: true, amount: 20, isPassive: false),
        Income(name: "Rebrickable", symbol: .shippingbox, isLiquid: true, amount: 7, isPassive: true)
    ]
    let backupExpenses = [
        Expense(name: "Electricity", symbol: .bolt, category: .variable, baseAmount: 200),
        Expense(name: "Water", symbol: .drop, category: .variable, baseAmount: 50),
        Expense(name: "Property Tax", symbol: .house, category: .fixed, baseAmount: 360),
        Expense(name: "MBNA Card", symbol: .creditcard, category: .discretionary, baseAmount: 0, children: [
            Expense(name: "Groceries", symbol: .basket, category: .variable, baseAmount: 500),
            Expense(name: "Repairs", symbol: .hammer, category: .intermittent, baseAmount: 200),
            Expense(name: "Gifts", symbol: .gift, category: .intermittent, baseAmount: 150),
            Expense(name: "Internet", symbol: .wifi, category: .fixed, baseAmount: 70),
            Expense(name: "Phone Plans", symbol: .iphone, category: .fixed, baseAmount: 60),
            Expense(name: "Take Out", symbol: .takeoutbag, category: .discretionary, baseAmount: 50),
            Expense(name: "Card Fee", symbol: .creditcard, category: .fixed, baseAmount: 10)
        ]),
        Expense(name: "Rogers Red Card", symbol: .creditcard, category: .discretionary, baseAmount: 0, children: [
            Expense(name: "Vacations", symbol: .airplane, category: .discretionary, baseAmount: 200),
            Expense(name: "TYT", symbol: .tv, category: .discretionary, baseAmount: 7),
            Expense(name: "Weed", symbol: .pills, category: .discretionary, baseAmount: 3)
        ]),
        Expense(name: "Tangerine Card", symbol: .creditcard, category: .discretionary, baseAmount: 0, children: [
            Expense(name: "LEGO", symbol: .shippingbox, category: .discretionary, baseAmount: 50),
            Expense(name: "Entertainment", symbol: .ticket, category: .discretionary, baseAmount: 40),
            Expense(name: "YouTube", symbol: .tv, category: .fixed, baseAmount: 21),
            Expense(name: "Wonderland", symbol: .ticket, category: .fixed, baseAmount: 12),
            Expense(name: "Dentist", symbol: .stethoscope, category: .intermittent, baseAmount: 10),
            Expense(name: "Domains", symbol: .icloud, category: .fixed, baseAmount: 4)
        ])
    ]
    let backupCreditCards = [
        CreditCard(name: "MBNA", colorName: .gray, cardFee: 100, pointsPerDollar: 5, pointValue: 0.01, monthlySpend: 2000),
        CreditCard(name: "Rogers Red", colorName: .red, cardFee: 0, pointsPerDollar: 1.5, pointValue: 0.01, monthlySpend: 1000),
        CreditCard(name: "Tangerine", colorName: .orange, cardFee: 0, pointsPerDollar: 2, pointValue: 0.01, monthlySpend: 500),
    ]
    let models: [any PersistentModel] = backupAssets + backupDebts + backupIncome + backupExpenses + backupCreditCards
    for model in models {
        context.insert(model)
    }
}
#endif
