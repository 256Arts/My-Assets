//
//  EntityActionIntents.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2026-06-29.
//  Copyright © 2026 256 Arts Developer. All rights reserved.
//

import AppIntents
import SwiftData

// MARK: - Helpers

/// Persists pending changes and re-publishes the Spotlight/Siri index. Every write intent ends here.
@MainActor
private func commitAndReindex() async {
    try? sharedModelContainer.mainContext.save()
    await refreshAppEntityIndex()
}

@MainActor
private func model<T: PersistentModel>(_ type: T.Type, for id: PersistentIdentifier) -> T? {
    (try? sharedModelContainer.mainContext.fetch(FetchDescriptor<T>()))?.first { $0.persistentModelID == id }
}

/// `Expense.Category` exposed to Siri so a new expense can be classified by voice.
extension Expense.Category: @retroactive AppEnum {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation { "Expense Category" }
    public static var caseDisplayRepresentations: [Expense.Category: DisplayRepresentation] {
        [.fixed: "Fixed", .variable: "Variable", .intermittent: "Intermittent", .discretionary: "Discretionary", .savings: "Savings"]
    }
}

// MARK: - Create

struct AddAssetIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Asset"
    static var description = IntentDescription("Adds a new asset to My Assets.")

    @Parameter(title: "Name", requestValueDialog: "What's the asset called?")
    var name: String
    @Parameter(title: "Value", requestValueDialog: "What's it worth?")
    var value: Double
    @Parameter(title: "Annual Interest (%)", default: 0)
    var interestPercent: Double

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<AssetEntity> & ProvidesDialog {
        let asset = Asset(name: name, value: value, annualInterestFraction: interestPercent / 100)
        sharedModelContainer.mainContext.insert(asset)
        await commitAndReindex()
        return .result(value: AssetEntity(asset), dialog: "Added \(name) to your assets.")
    }
}

struct AddDebtIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Debt"
    static var description = IntentDescription("Adds a new debt to My Assets.")

    @Parameter(title: "Name", requestValueDialog: "What's the debt called?")
    var name: String
    @Parameter(title: "Amount Owed", requestValueDialog: "How much is owed?")
    var value: Double
    @Parameter(title: "Monthly Payment", requestValueDialog: "How much do you pay each month?")
    var paymentAmount: Double
    @Parameter(title: "Annual Interest (%)", default: 0)
    var interestPercent: Double

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<DebtEntity> & ProvidesDialog {
        let debt = Debt(name: name, value: value, paymentAmount: paymentAmount)
        debt.annualInterestFraction = interestPercent / 100
        sharedModelContainer.mainContext.insert(debt)
        await commitAndReindex()
        return .result(value: DebtEntity(debt), dialog: "Added \(name) to your debts.")
    }
}

struct AddIncomeIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Income"
    static var description = IntentDescription("Adds a new monthly income to My Assets.")

    @Parameter(title: "Name", requestValueDialog: "What's the income called?")
    var name: String
    @Parameter(title: "Monthly Amount", requestValueDialog: "How much per month?")
    var amount: Double
    @Parameter(title: "Passive", default: false)
    var isPassive: Bool

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<IncomeEntity> & ProvidesDialog {
        let income = Income(name: name, symbol: .defaultSymbol, isLiquid: true, amount: amount, isPassive: isPassive)
        income.frequency = .monthly
        sharedModelContainer.mainContext.insert(income)
        await commitAndReindex()
        return .result(value: IncomeEntity(income), dialog: "Added \(name) to your income.")
    }
}

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var description = IntentDescription("Adds a new monthly expense to My Assets.")

    @Parameter(title: "Name", requestValueDialog: "What's the expense called?")
    var name: String
    @Parameter(title: "Monthly Amount", requestValueDialog: "How much per month?")
    var amount: Double
    @Parameter(title: "Category", default: .discretionary)
    var category: Expense.Category

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<ExpenseEntity> & ProvidesDialog {
        let expense = Expense(name: name, category: category, baseAmount: amount)
        expense.frequency = .monthly
        sharedModelContainer.mainContext.insert(expense)
        await commitAndReindex()
        return .result(value: ExpenseEntity(expense), dialog: "Added \(name) to your expenses.")
    }
}

// MARK: - Delete

struct DeleteAssetIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete Asset"
    static var description = IntentDescription("Removes an asset from My Assets.")

    @Parameter(title: "Asset")
    var target: AssetEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let asset = model(Asset.self, for: target.id) {
            sharedModelContainer.mainContext.delete(asset)
            await commitAndReindex()
        }
        return .result(dialog: "Deleted \(target.name).")
    }
}

struct DeleteDebtIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete Debt"
    static var description = IntentDescription("Removes a debt from My Assets.")

    @Parameter(title: "Debt")
    var target: DebtEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let debt = model(Debt.self, for: target.id) {
            sharedModelContainer.mainContext.delete(debt)
            await commitAndReindex()
        }
        return .result(dialog: "Deleted \(target.name).")
    }
}

struct DeleteIncomeIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete Income"
    static var description = IntentDescription("Removes an income from My Assets.")

    @Parameter(title: "Income")
    var target: IncomeEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let income = model(Income.self, for: target.id) {
            sharedModelContainer.mainContext.delete(income)
            await commitAndReindex()
        }
        return .result(dialog: "Deleted \(target.name).")
    }
}

struct DeleteExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete Expense"
    static var description = IntentDescription("Removes an expense from My Assets.")

    @Parameter(title: "Expense")
    var target: ExpenseEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let expense = model(Expense.self, for: target.id) {
            sharedModelContainer.mainContext.delete(expense)
            await commitAndReindex()
        }
        return .result(dialog: "Deleted \(target.name).")
    }
}
