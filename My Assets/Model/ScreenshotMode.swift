import Foundation
import SwiftData
import SwiftUI

/// Deterministic demo state for App Store screenshots, switched on by the `-screenshotMode` launch
/// argument that `My AssetsUITests/ScreenshotTests.swift` passes.
///
/// A fresh install is empty, so a shot of the summary would otherwise be the empty state. The seed
/// is `previewContainer` — already in-memory, already CloudKit-free, already the demo portfolio the
/// previews use — so a screenshot run neither shows nor disturbs the real data on the machine
/// taking the shots, and there is only one set of demo numbers to keep looking good.
///
/// Not DEBUG-gated, and neither is the demo data it leans on: the shared screenshot runner builds
/// Release, so the shots carry no developer UI.
enum ScreenshotMode {

    /// Whether this launch is a screenshot run. Read once, by `sharedModelContainer`.
    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains("-screenshotMode")
    }

    /// The store a screenshot run reads from.
    @MainActor
    static var container: ModelContainer {
        let container = previewContainer
        guard verify(container.mainContext) else { return container }
        report("""
            ready — in-memory store, no CloudKit; seeded \(previewAssets.count) assets, \
            \(previewDebts.count) debts, \(previewIncome.count) income sources, \
            \(previewExpenses.count) expenses, \(previewUpcomingSpends.count) upcoming spends, \
            \(previewCreditCards.count) credit cards
            """)
        return container
    }

    // MARK: - Saying what happened

    /// What this launch seeded, in one line, for the walk and for the shared runner.
    ///
    /// A failed walk otherwise reports only "seeded content never appeared", which is equally true
    /// of a store that never seeded, a screen that never opened, and an identifier renamed last
    /// week. The walk reads this out of the accessibility tree before its first shot and prints it
    /// on any miss, and the fixed prefix makes it greppable in the build log.
    private(set) static var status = "the seed has not run"

    private static func report(_ line: String) {
        status = line
        print("SCREENSHOT MODE: \(line)")
    }

    /// Whether `context` is the throwaway store this mode promises, checked before handing
    /// `previewContainer` over to the app.
    ///
    /// The damage a screenshot run can do is writing demo financial data into the user's own — and
    /// by the time anybody notices, CloudKit has synced it. So the hand-over stops at the door
    /// rather than afterwards, and says which half of the contract failed.
    @MainActor
    private static func verify(_ context: ModelContext) -> Bool {
        let configurations = context.container.configurations
        let onDisk = configurations.filter { !$0.isStoredInMemoryOnly }
        guard onDisk.isEmpty else {
            report("""
                REFUSED — the container is on disk (\(onDisk.map(\.name).joined(separator: ", "))), \
                so seeding would write demo financial data into a real store. Build it with \
                ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none).
                """)
            return false
        }
        let synced = configurations.filter { $0.cloudKitContainerIdentifier != nil }
        guard synced.isEmpty else {
            report("""
                REFUSED — the container still syncs with CloudKit \
                (\(synced.compactMap(\.cloudKitContainerIdentifier).joined(separator: ", "))), so the \
                real account's financial data would arrive in the store being photographed. Add \
                cloudKitDatabase: .none.
                """)
            return false
        }
        return true
    }
}

extension View {

    /// Carries `ScreenshotMode.status` into the accessibility tree, where the walk reads it.
    ///
    /// Nothing on a normal launch; on a screenshot run, a one-point transparent label — present to
    /// XCUITest, invisible in the shot. It is how the walk can tell a seed that never ran from a
    /// screen that never opened, neither of which the app can report any other way: a simulator
    /// app's `print` does not reach the build log, and there is no file path both the app and the
    /// runner can write.
    @ViewBuilder
    func screenshotModeStatus() -> some View {
        if ScreenshotMode.isActive {
            overlay(alignment: .topLeading) {
                Text(ScreenshotMode.status)
                    .font(.system(size: 1))
                    .opacity(0.001)
                    .accessibilityIdentifier("ScreenshotMode.Status")
                    .allowsHitTesting(false)
            }
        } else {
            self
        }
    }
}
