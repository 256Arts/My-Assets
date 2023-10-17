//
//  My_Assets__watchOS_App.swift
//  My Assets (watchOS) Watch App
//
//  Created by Jayden Irwin on 2023-07-28.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct My_Assets__watchOS__Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [Asset.self, Debt.self, Stock.self, Income.self, Expense.self])
    }
}

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter
}()

let timeRemainingFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.maximumUnitCount = 1
    formatter.allowedUnits = [.day, .month, .year]
    return formatter
}()
