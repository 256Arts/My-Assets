//
//  SpotlightIndexer.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2026-06-29.
//  Copyright © 2026 256 Arts Developer. All rights reserved.
//

import CoreSpotlight

/// Re-publishes the app's entities to the on-device Spotlight / Siri semantic index, so the new
/// Siri and Apple Intelligence can find and reference the user's assets, debts, income, and
/// expenses by name. Called on launch and after every write intent. Best-effort: indexing
/// failures never disrupt the app.
@MainActor
func refreshAppEntityIndex() async {
    let index = CSSearchableIndex.default()
    do {
        try await index.indexAppEntities(AssetEntity.defaultQuery.suggestedEntities())
        try await index.indexAppEntities(DebtEntity.defaultQuery.suggestedEntities())
        try await index.indexAppEntities(IncomeEntity.defaultQuery.suggestedEntities())
        try await index.indexAppEntities(ExpenseEntity.defaultQuery.suggestedEntities())
    } catch {
        // Indexing is advisory; leave the previous index in place on failure.
    }
}
