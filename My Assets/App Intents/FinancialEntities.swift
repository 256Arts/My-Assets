//
//  FinancialEntities.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2026-06-29.
//  Copyright © 2026 256 Arts Developer. All rights reserved.
//

import AppIntents
import CoreSpotlight
import Foundation
import SwiftData

/// App Intents requires an entity's `ID` to be `EntityIdentifierConvertible`. SwiftData's
/// `PersistentIdentifier` is `Codable`, so we bridge it through its encoded form — letting the
/// entities key on the real persistent identity instead of a fragile derived string.
extension PersistentIdentifier: @retroactive EntityIdentifierConvertible {
    public var entityIdentifierString: String {
        (try? JSONEncoder().encode(self))?.base64EncodedString() ?? ""
    }
    public static func entityIdentifier(for entityIdentifierString: String) -> PersistentIdentifier? {
        guard let data = Data(base64Encoded: entityIdentifierString) else { return nil }
        return try? JSONDecoder().decode(PersistentIdentifier.self, from: data)
    }
}

/// `NSUserActivity` types used to make a singular on-screen item (a detail screen) known to Siri.
/// Registered in Info.plist under `NSUserActivityTypes`.
enum AppActivityType {
    static let asset = "com.jaydenirwin.myassets.asset"
    static let debt = "com.jaydenirwin.myassets.debt"
    static let income = "com.jaydenirwin.myassets.income"
    static let expense = "com.jaydenirwin.myassets.expense"
}

// MARK: - Shared shape

/// The four core model types (`Asset`, `Debt`, `Income`, `Expense`) all surface to Siri and
/// Apple Intelligence as the same shape: a stable identity, a name, a one-line money detail, and
/// an icon. Capturing that here keeps the concrete entities to a few lines each. Conforming to
/// `IndexedEntity` is what feeds them into the on-device semantic index the new Siri searches.
protocol FinancialItemEntity: AppEntity, IndexedEntity {
    var id: PersistentIdentifier { get }
    var name: String { get }
    /// A short, already-formatted money string (e.g. "$10,000" or "$1,200 / mo").
    var detail: String { get }
    /// An SF Symbol name.
    var symbolName: String { get }
}

extension FinancialItemEntity {
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(detail)", image: .init(systemName: symbolName))
    }
    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(contentType: .content)
        attributes.title = name
        attributes.contentDescription = detail
        return attributes
    }
}

// MARK: - Query helpers

/// Snapshots every stored `Model` into an entity. Personal-finance stores hold only a handful of
/// rows, so fetching the lot and mapping in memory is simpler (and safer against deletes) than
/// per-id faulting.
@MainActor
func fetchAllEntities<Model: PersistentModel, Entity>(_ map: (Model) -> Entity) -> [Entity] {
    let models = (try? sharedModelContainer.mainContext.fetch(FetchDescriptor<Model>())) ?? []
    return models.map(map)
}

@MainActor
func resolveEntities<Model: PersistentModel, Entity>(_ ids: [PersistentIdentifier], _ map: (Model) -> Entity) -> [Entity] {
    let wanted = Set(ids)
    let models = (try? sharedModelContainer.mainContext.fetch(FetchDescriptor<Model>())) ?? []
    return models.filter { wanted.contains($0.persistentModelID) }.map(map)
}

private func money(_ value: Double) -> String {
    currencyFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

// MARK: - Asset

struct AssetEntity: FinancialItemEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Asset" }
    static let defaultQuery = AssetEntityQuery()

    let id: PersistentIdentifier
    let name: String
    let detail: String
    let symbolName: String

    @MainActor
    init(_ asset: Asset) {
        id = asset.persistentModelID
        name = asset.name ?? "Asset"
        detail = money(asset.currentValue)
        symbolName = (asset.symbol ?? .defaultSymbol).rawValue
    }
}

struct AssetEntityQuery: EntityStringQuery {
    @MainActor func entities(for identifiers: [PersistentIdentifier]) async throws -> [AssetEntity] {
        resolveEntities(identifiers, AssetEntity.init)
    }
    @MainActor func entities(matching string: String) async throws -> [AssetEntity] {
        try await suggestedEntities().filter { $0.name.localizedCaseInsensitiveContains(string) }
    }
    @MainActor func suggestedEntities() async throws -> [AssetEntity] {
        fetchAllEntities(AssetEntity.init)
    }
}

// MARK: - Debt

struct DebtEntity: FinancialItemEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Debt" }
    static let defaultQuery = DebtEntityQuery()

    let id: PersistentIdentifier
    let name: String
    let detail: String
    let symbolName: String

    @MainActor
    init(_ debt: Debt) {
        id = debt.persistentModelID
        name = debt.name ?? "Debt"
        detail = money(debt.currentValue)
        symbolName = (debt.symbol ?? .defaultSymbol).rawValue
    }
}

struct DebtEntityQuery: EntityStringQuery {
    @MainActor func entities(for identifiers: [PersistentIdentifier]) async throws -> [DebtEntity] {
        resolveEntities(identifiers, DebtEntity.init)
    }
    @MainActor func entities(matching string: String) async throws -> [DebtEntity] {
        try await suggestedEntities().filter { $0.name.localizedCaseInsensitiveContains(string) }
    }
    @MainActor func suggestedEntities() async throws -> [DebtEntity] {
        fetchAllEntities(DebtEntity.init)
    }
}

// MARK: - Income

struct IncomeEntity: FinancialItemEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Income" }
    static let defaultQuery = IncomeEntityQuery()

    let id: PersistentIdentifier
    let name: String
    let detail: String
    let symbolName: String

    @MainActor
    init(_ income: Income) {
        id = income.persistentModelID
        name = income.name ?? "Income"
        detail = "\(money(income.monthlyEarnings ?? 0)) / mo"
        symbolName = (income.symbol ?? .defaultSymbol).rawValue
    }
}

struct IncomeEntityQuery: EntityStringQuery {
    @MainActor func entities(for identifiers: [PersistentIdentifier]) async throws -> [IncomeEntity] {
        resolveEntities(identifiers, IncomeEntity.init)
    }
    @MainActor func entities(matching string: String) async throws -> [IncomeEntity] {
        try await suggestedEntities().filter { $0.name.localizedCaseInsensitiveContains(string) }
    }
    @MainActor func suggestedEntities() async throws -> [IncomeEntity] {
        fetchAllEntities(IncomeEntity.init)
    }
}

// MARK: - Expense

struct ExpenseEntity: FinancialItemEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Expense" }
    static let defaultQuery = ExpenseEntityQuery()

    let id: PersistentIdentifier
    let name: String
    let detail: String
    let symbolName: String

    @MainActor
    init(_ expense: Expense) {
        id = expense.persistentModelID
        name = expense.name ?? "Expense"
        detail = "\(money(expense.monthlyCost())) / mo"
        symbolName = (expense.symbol ?? .defaultSymbol).rawValue
    }
}

struct ExpenseEntityQuery: EntityStringQuery {
    @MainActor func entities(for identifiers: [PersistentIdentifier]) async throws -> [ExpenseEntity] {
        resolveEntities(identifiers, ExpenseEntity.init)
    }
    @MainActor func entities(matching string: String) async throws -> [ExpenseEntity] {
        try await suggestedEntities().filter { $0.name.localizedCaseInsensitiveContains(string) }
    }
    @MainActor func suggestedEntities() async throws -> [ExpenseEntity] {
        // Top-level expenses only — child expenses (a debt's interest/principal split) aren't
        // separately meaningful to Siri, matching how `FinancialData` filters `parent == nil`.
        let expenses = (try? sharedModelContainer.mainContext.fetch(FetchDescriptor<Expense>())) ?? []
        return expenses.filter { $0.parent == nil }.map(ExpenseEntity.init)
    }
}
