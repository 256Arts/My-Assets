//
//  MyAssetsShortcuts.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2026-06-29.
//  Copyright © 2026 256 Arts Developer. All rights reserved.
//

import AppIntents

/// Surfaces the app's intents to Siri, Spotlight, and the Shortcuts app with spoken phrases,
/// so the most common big-picture questions and quick captures work hands-free out of the box.
struct MyAssetsShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetNetWorthIntent(),
            phrases: [
                "What's my net worth in \(.applicationName)",
                "Check my net worth in \(.applicationName)"
            ],
            shortTitle: "Net Worth",
            systemImageName: "chart.line.uptrend.xyaxis"
        )
        AppShortcut(
            intent: GetBalanceIntent(),
            phrases: [
                "What's my balance in \(.applicationName)",
                "Check my liquid balance in \(.applicationName)"
            ],
            shortTitle: "Liquid Balance",
            systemImageName: "banknote"
        )
        AppShortcut(
            intent: GetLiveOffTimeIntent(),
            phrases: [
                "How long can I live off my savings in \(.applicationName)"
            ],
            shortTitle: "Live Off Savings",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: GetNetWorthProjectionIntent(),
            phrases: [
                "Project my net worth in \(.applicationName)"
            ],
            shortTitle: "5-Year Projection",
            systemImageName: "chart.line.uptrend.xyaxis.circle"
        )
        AppShortcut(
            intent: AddAssetIntent(),
            phrases: [
                "Add an asset in \(.applicationName)",
                "Add an asset to \(.applicationName)"
            ],
            shortTitle: "Add Asset",
            systemImageName: "plus.circle"
        )
        AppShortcut(
            intent: AddDebtIntent(),
            phrases: [
                "Add a debt in \(.applicationName)"
            ],
            shortTitle: "Add Debt",
            systemImageName: "minus.circle"
        )
        AppShortcut(
            intent: AddIncomeIntent(),
            phrases: [
                "Add income in \(.applicationName)"
            ],
            shortTitle: "Add Income",
            systemImageName: "tray.and.arrow.down"
        )
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Add an expense in \(.applicationName)"
            ],
            shortTitle: "Add Expense",
            systemImageName: "tray.and.arrow.up"
        )
    }
}
