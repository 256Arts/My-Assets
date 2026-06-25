# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**My Assets** is a personal net-worth / cash-flow tracking app built in SwiftUI. It runs as a native app across iOS, macOS, visionOS (`xros`), and watchOS. There is no CocoaPods/SPM dependency manifest — it relies entirely on Apple frameworks (SwiftUI, SwiftData, Swift Charts, Swift Testing).

## Build, Run & Test

This is an Xcode project (`My Assets.xcodeproj`). Two shared schemes exist: `My Assets` (iOS/macOS/visionOS) and `My Assets (watchOS) Watch App`. Pick a concrete `-destination` for the current toolchain (e.g. an available iOS Simulator from `xcrun simctl list`).

```sh
# Build the main app
xcodebuild -scheme "My Assets" -destination '<destination>' build

# Run the full test suite (uses the Swift Testing framework, not XCTest)
xcodebuild -scheme "My Assets" -destination '<destination>' test

# Run a single test by name
xcodebuild -scheme "My Assets" -destination '<destination>' test -only-testing:"My AssetsTests/testAsset"
```

Tests live in `My AssetsTests/` and use Swift Testing (`@Test` / `#expect`), not XCTest. They focus on the financial math in the model layer (compound interest on assets, debt amortization, "live off" runway, net-worth percentiles).

## Backlog

If `REMINDERS.md` exists in the repo root, it is a personal backlog exported from Apple Reminders (gitignored, not committed). Each `- [ ]` line is one to-do item. Many entries are terse shorthand meaningful only to the user — treat it as a source of candidate work, not a spec, and ask before acting on cryptic items. Refresh it with the `export-reminders` skill.

## Secrets

`My Assets/Secrets.swift` is **gitignored** (see `.gitignore`) and holds the Alpha Vantage API key. It is not in version control, so a fresh checkout will fail to compile until this file is recreated with an `enum Secrets { static let alphaVantageKey = "..." }`. Do not commit it.

## Architecture

### Persistence: SwiftData + CloudKit
All user data is stored via **SwiftData** `@Model` classes, synced through CloudKit. Because of CloudKit's requirements, **every model property is optional or has a default** — expect `Bool?`, `Double?`, `String?` everywhere, with extensive `?? default` unwrapping in computed properties. Keep this pattern when adding model fields.

The model container is configured in `MyAssetsApp.swift`. Note the build-conditional swap: simulator and macOS debug builds use the in-memory `previewContainer` (seeded sample data); device/release builds use the real CloudKit-backed container. The registered model types are: `Asset`, `Debt`, `Stock`, `UpcomingSpend`, `Income`, `Expense`, `CreditCard`.

### The `FinancialData` aggregate (`Model/FinancialData.swift`)
Views do **not** compute financial summaries directly from `@Query` results. Instead, `RootTabView` reads all the `@Query` arrays and constructs a single `@Observable FinancialData` object, injected via `.environment(financialData)`. This is the central calculation engine — net worth, balance, total/passive income & expenses, weighted-average interest, and projections all live here.

Key concept: nearly everything is **time-projected**. `currentValue(at: date)`, `netWorth(at:type:)`, and `balance(at:)` extrapolate values into the future (or past) using compound-interest and future-value-of-annuity formulas. The `NetWorthType` enum distinguishes three scenarios: `.working` (normal), `.notWorking` (if you quit your job), and `.natural` (assets/debts and their interest only, no human income or expenses). Charts and the summary screen depend heavily on these projections.

Stocks are unified into the asset list at read time: `FinancialData.assets` concatenates `nonStockAssets` with `stocks` mapped through `Asset(stock:)`.

### Insights (`Model/InsightsGenerator.swift`)
`InsightsGenerator` wraps a `FinancialData` instance to produce derived "insights" — e.g. how many months you could live off savings (`liveOffMonths`), average interest rates, and net-worth percentile ranking against reference data in `Model/WorldFinanceStats.swift`.

### External data: Alpha Vantage (`Model/AlphaVantage.swift`)
A singleton `actor` (`AlphaVantage.shared`) fetches monthly stock prices and crypto exchange rates from the Alpha Vantage REST API. It parses raw JSON dictionaries (not `Codable` structs) and returns `(price, prevPrice, prevDate)` tuples used to populate `Stock` values.

### View structure
Views are grouped by feature directory under `My Assets/`: `Summary/`, `Assets & Debts/`, `Income/`, `Expenses/`, `Credit Cards/`. `RootTabView.swift` is the iOS/macOS tab host (sidebar-adaptable on macOS, with tab customization persisted via `@AppStorage`). The watchOS target (`My Assets (watchOS) Watch App/`) has its own parallel set of slimmed-down views and root tab view but shares the model layer.

Reusable form components live at the top level of `My Assets/`: `CurrencyField`, `PercentField`, `AmountRow`, `SymbolPicker`/`SymbolPickerLink`, `ColorPicker`/`ColorPickerLink`. App-wide `NumberFormatter`s (`currencyFormatter`, `percentFormatter`, etc.) are defined as globals in `MyAssetsApp.swift`.

### Conventions
- `TimeInterval` is extended with `.month` and `.year` constants (`Model/TimeInterval.swift`) — these are used throughout the math instead of hardcoded seconds.
- `UserDefaults` keys and registration live in `Model/UserDefaults.swift`; settings are read via `@AppStorage(UserDefaults.Key.…)`.
- Enums like `Symbol` (SF Symbol names) and `ColorName` provide Codable, SwiftData-storable wrappers for icons and colors.
- Sample/seed data for previews and debug-only backup restore lives in `PreviewContainer.swift` and the `#if DEBUG` block of `Secrets.swift`.
