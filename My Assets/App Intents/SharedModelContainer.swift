//
//  SharedModelContainer.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2026-06-29.
//  Copyright © 2026 256 Arts Developer. All rights reserved.
//

import SwiftData

/// The single SwiftData container shared by the app UI and every App Intent.
///
/// App Intents can be launched by Siri while the app is in the background, so they need
/// the same store the UI uses. This mirrors the build-conditional swap that `MyAssetsApp`
/// used to perform inline: simulator and macOS debug builds use the in-memory, seeded
/// `previewContainer`; device/release builds use the real CloudKit-backed store.
@MainActor
let sharedModelContainer: ModelContainer = {
    #if targetEnvironment(simulator) || ((os(macOS) || targetEnvironment(macCatalyst)) && DEBUG)
    return previewContainer
    #else
    return try! ModelContainer(for: Asset.self, Debt.self, Stock.self, UpcomingSpend.self, Income.self, Expense.self, CreditCard.self)
    #endif
}()

extension FinancialData {

    /// Builds the aggregate from everything currently stored in `context`.
    /// App Intents have no SwiftUI `@Query` to read from, so they assemble `FinancialData`
    /// this way and inherit the full calculation engine for free.
    @MainActor
    convenience init(modelContext context: ModelContext) {
        func all<T: PersistentModel>(_ type: T.Type) -> [T] {
            (try? context.fetch(FetchDescriptor<T>())) ?? []
        }
        self.init(
            nonStockAssets: all(Asset.self),
            stocks: all(Stock.self),
            debts: all(Debt.self),
            income: all(Income.self),
            expenses: all(Expense.self)
        )
    }
}
