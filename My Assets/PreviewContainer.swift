//
//  PreviewContainer.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2023-11-06.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

#if DEBUG
import SwiftData

@MainActor
let previewAssets = [
    Asset(name: "House", symbol: .house, value: 500_000),
    Asset(name: "Bank Account", symbol: .bank, value: 10_000),
    Asset(name: "Stocks", symbol: .stocks, value: 100_000),
    Asset(name: "Car", symbol: .car, value: 30_000),
    Asset(name: "Bitcoin Wallet", symbol: .bitcoin, value: 50_000)
]
@MainActor
let previewDebts = [
    Debt(name: "Mortgage", symbol: .house, value: 150_000),
    Debt(name: "Car Loan", symbol: .car, value: 15_000)
]
@MainActor
let previewIncome = [
    Income(name: "Work", symbol: .building, isLiquid: true, amount: 10_000, isPassive: false),
    Income(name: "App Sales", symbol: .app, isLiquid: true, amount: 1_000, isPassive: true),
    Income(name: "Etsy Store", symbol: .shippingbox, isLiquid: true, amount: 200, isPassive: false)
]
@MainActor
let previewExpenses = [
    Expense(name: "Electricity", symbol: .bolt, category: .variable, baseAmount: 150),
    Expense(name: "Water", symbol: .drop, category: .variable, baseAmount: 100),
    Expense(name: "Property Tax", symbol: .house, category: .fixed, baseAmount: 300),
    Expense(name: "Credit Card", symbol: .creditcard, category: .discretionary, baseAmount: 2_000),
    Expense(name: "Internet", symbol: .wifi, category: .fixed, baseAmount: 100),
    Expense(name: "Phone Plan", symbol: .iphone, category: .fixed, baseAmount: 100),
    Expense(name: "Streaming", symbol: .tv, category: .fixed, baseAmount: 25),
    Expense(name: "Take Out", symbol: .takeoutbag, category: .discretionary, baseAmount: 50),
    Expense(name: "Repairs", symbol: .hammer, category: .intermittent, baseAmount: 200),
    Expense(name: "Cloud Storage", symbol: .icloud, category: .fixed, baseAmount: 10),
    Expense(name: "Home Insurance", symbol: .house, category: .fixed, baseAmount: 100),
    Expense(name: "Train Pass", symbol: .tram, category: .intermittent, baseAmount: 30)
]
@MainActor
let previewCreditCards = [
    CreditCard(name: "VISA", colorName: .gray, cardFee: 50, pointsPerDollar: 2, pointValue: 0.01, monthlySpend: 1000),
    CreditCard(name: "Mastercard", colorName: .red, cardFee: 0, pointsPerDollar: 3, pointValue: 0.01, monthlySpend: 1000),
    CreditCard(name: "Amex", colorName: .blue, cardFee: 1000, pointsPerDollar: 5, pointValue: 0.01, monthlySpend: 1000),
]

@MainActor
let previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
    let container = try! ModelContainer(for: Asset.self, Debt.self, Stock.self, UpcomingSpend.self, Income.self, Expense.self, CreditCard.self, configurations: config)

    let models: [any PersistentModel] = previewAssets + previewDebts + previewIncome + previewExpenses + previewCreditCards
    for model in models {
        container.mainContext.insert(model)
    }
    
    return container
}()
#endif
