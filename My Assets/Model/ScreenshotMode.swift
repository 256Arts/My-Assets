import Foundation
import SwiftData

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
    static var container: ModelContainer { previewContainer }
}
