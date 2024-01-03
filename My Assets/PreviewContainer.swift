//
//  PreviewContainer.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2023-11-06.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

#if DEBUG
import SwiftData

//@MainActor
//let previewContainer: ModelContainer = {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Asset.self, Debt.self, Stock.self, UpcomingSpend.self, Income.self, Expense.self, configurations: config)
//
//    let models: [any PersistentModel] = [
//        Asset(name: "House", symbol: .house, value: 500_000),
//        Asset(name: "Bank Account", symbol: .bank, value: 10_000),
//        Asset(name: "Stocks", symbol: .stocks, value: 100_000),
//        Asset(name: "Car", symbol: .car, value: 30_000),
//        Asset(name: "Bitcoin Wallet", symbol: .bitcoin, value: 50_000),
//        
//        Debt(name: "Mortgage", symbol: .house, value: 150_000),
//        Debt(name: "Car Loan", symbol: .car, value: 15_000),
//        
//        Income(name: "Work", symbol: .building, isLiquid: true, monthlyEarnings: 10_000, isPassive: false),
//        Income(name: "App Sales", symbol: .app, isLiquid: true, monthlyEarnings: 1_000, isPassive: true),
//        Income(name: "Etsy Store", symbol: .shippingbox, isLiquid: true, monthlyEarnings: 200, isPassive: false),
//        
//        Expense(name: "Electricity", symbol: .bolt, category: .variable, monthlyCost: 150),
//        Expense(name: "Water", symbol: .drop, category: .variable, monthlyCost: 100),
//        Expense(name: "Property Tax", symbol: .house, category: .fixed, monthlyCost: 300),
//        Expense(name: "Credit Card", symbol: .creditcard, category: .discretionary, monthlyCost: 2_000),
//        Expense(name: "Internet", symbol: .wifi, category: .fixed, monthlyCost: 100),
//        Expense(name: "Phone Plan", symbol: .iphone, category: .fixed, monthlyCost: 100),
//        Expense(name: "Streaming", symbol: .tv, category: .fixed, monthlyCost: 25),
//        Expense(name: "Take Out", symbol: .takeoutbag, category: .discretionary, monthlyCost: 50),
//        Expense(name: "Repairs", symbol: .hammer, category: .intermittent, monthlyCost: 200),
//        Expense(name: "Cloud Storage", symbol: .icloud, category: .fixed, monthlyCost: 10),
//        Expense(name: "Home Insurance", symbol: .house, category: .fixed, monthlyCost: 100),
//        Expense(name: "Train Pass", symbol: .tram, category: .intermittent, monthlyCost: 30)
//    ]
//    for model in models {
//        container.mainContext.insert(model)
//    }
//    
//    return container
//}()
#endif
