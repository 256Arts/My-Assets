//
//  FinancialQueryIntents.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2026-06-29.
//  Copyright © 2026 256 Arts Developer. All rights reserved.
//

import AppIntents

/// Lets an App Intent ask the running app to switch tabs (e.g. after "Open my assets").
/// `RootTabView` observes this and syncs its selection.
@MainActor
@Observable
final class IntentNavigator {
    static let shared = IntentNavigator()
    private init() {}

    var requestedTab: RootTabView.Tabs?
}

// MARK: - Read queries

/// Convenience for the read intents: a fresh aggregate over the current store.
@MainActor
private func currentFinancialData() -> FinancialData {
    FinancialData(modelContext: sharedModelContainer.mainContext)
}

private func money(_ value: Double) -> String {
    currencyFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

struct GetNetWorthIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Net Worth"
    static var description = IntentDescription("Reports your current net worth — assets minus debts.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let value = money(currentFinancialData().netWorth(at: .now, type: .working))
        return .result(dialog: "Your net worth is \(value).")
    }
}

struct GetBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Liquid Balance"
    static var description = IntentDescription("Reports the total value of your liquid assets.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let value = money(currentFinancialData().balance(at: .now))
        return .result(dialog: "Your liquid balance is \(value).")
    }
}

struct GetLiveOffTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "How Long Could I Live Off Savings"
    static var description = IntentDescription("Estimates how long you could live off your savings and passive income.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let time = InsightsGenerator(data: currentFinancialData()).liveOffTimeString
        if time == "forever" {
            return .result(dialog: "Your passive income covers your expenses, so you could live off your savings indefinitely.")
        }
        return .result(dialog: "You could live off your savings for about \(time).")
    }
}

struct GetNetWorthProjectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Project Net Worth in 5 Years"
    static var description = IntentDescription("Projects your net worth five years from now.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let value = InsightsGenerator(data: currentFinancialData()).netWorthIn5YearsString
        return .result(dialog: "In five years your net worth could be about \(value).")
    }
}

// MARK: - Open

struct OpenAssetIntent: OpenIntent {
    static var title: LocalizedStringResource = "Open Asset"
    @Parameter(title: "Asset") var target: AssetEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentNavigator.shared.requestedTab = .assetsAndDebts
        return .result()
    }
}

struct OpenDebtIntent: OpenIntent {
    static var title: LocalizedStringResource = "Open Debt"
    @Parameter(title: "Debt") var target: DebtEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentNavigator.shared.requestedTab = .assetsAndDebts
        return .result()
    }
}

struct OpenIncomeIntent: OpenIntent {
    static var title: LocalizedStringResource = "Open Income"
    @Parameter(title: "Income") var target: IncomeEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentNavigator.shared.requestedTab = .income
        return .result()
    }
}

struct OpenExpenseIntent: OpenIntent {
    static var title: LocalizedStringResource = "Open Expense"
    @Parameter(title: "Expense") var target: ExpenseEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentNavigator.shared.requestedTab = .expenses
        return .result()
    }
}
