import XCTest
#if canImport(UIKit)
import UIKit
#endif

/// Drives the app through the screens that become App Store screenshots and attaches each one to the
/// result bundle, where `Scripts/screenshots.sh` extracts them.
///
/// One test rather than one per screen: the shots are a walk through a single launch, and splitting
/// them would pay the launch — and the reseed — every time.
@MainActor
final class ScreenshotTests: XCTestCase {

    private var app: XCUIApplication!

    func testCaptureAppStoreScreenshots() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Everything the summary shows is a stored preference, so the shots would otherwise inherit
        // whatever the capturing Mac has switched off. Pinned through the argument domain, which
        // overrides the stored values for this launch alone and writes nothing back.
        app.launchArguments = [
            "-screenshotMode",
            "-summaryScreenShowBalance", "YES",
            "-summaryScreenBalanceShowChart", "YES",
            "-summaryScreenShowNetWorth", "YES",
            "-summaryScreenNetWorthShowChart", "YES",
            "-summaryScreenShowCashFlows", "YES",
            "-summaryScreenShowInsights", "YES",
            "-amountMarqueePeriod", "Month",
            "-amountMarqueeShowAsCombinedValue", "NO",
            // The on-device model's insights are a spinner, then prose that differs every run.
            "-summaryScreenShowCustomInsights", "NO"
        ]
        app.launch()

        #if os(macOS)
        openWindowIfNeeded()
        #endif

        checkSeedIsThrowaway()

        // Assets is where the seed is most obviously present, so prove it landed before shooting.
        activate(control("Assets/Debts"), "Assets/Debts tab")
        // Rows read as "House, $500,000.00" — the row's amount is part of its label, so match the name.
        let houseRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "House")).firstMatch
        waitFor(houseRow, "the seeded House row", shot: "02-assets-debts")
        settle()
        capture("02-assets-debts")

        activate(control("Income"), "Income tab")
        settle()
        capture("03-income")

        activate(control("Expenses"), "Expenses tab")
        settle()
        capture("04-expenses")

        activate(control("Credit Cards"), "Credit Cards tab")
        settle()
        capture("05-credit-cards")

        // Shot first on the product page, shot last here: the summary's charts are the slowest to
        // draw, and by now every projection they read has been computed.
        activate(control("Summary"), "Summary tab")
        settle()
        capture("01-summary")
    }

    // MARK: - The seed

    /// What the app said it seeded, read out of the accessibility tree.
    ///
    /// The app hangs `ScreenshotMode.status` on its root view (`.screenshotModeStatus()`). A walk
    /// that cannot find it is running against a build that has not adopted that modifier, which is
    /// worth saying plainly rather than reporting as an empty seed.
    private var seedStatus: String {
        let label = app.descendants(matching: .any)["ScreenshotMode.Status"]
        guard label.waitForExistence(timeout: 30) else {
            return "no ScreenshotMode.Status element — add .screenshotModeStatus() to the app's root view"
        }
        // A SwiftUI `Text` reaches XCUITest as the element's *value* on macOS and as its *label* on
        // iOS, so take whichever is filled in rather than betting on one.
        if let value = label.value as? String, !value.isEmpty { return value }
        return label.label
    }

    /// Stops the walk when the app did not seed the throwaway store.
    ///
    /// `ScreenshotMode.container` refuses to hand over a store that is on disk or still synced with
    /// CloudKit, because a screenshot run that reached the real store writes demo financial data into
    /// the user's own. The walk that followed would then photograph an empty app and fail on a
    /// missing row, which says nothing about why. Read the reason instead, before the first shot.
    private func checkSeedIsThrowaway() {
        let status = seedStatus
        print("SCREENSHOT MODE: \(status)")
        guard status.hasPrefix("ready") else {
            attach(XCTAttachment(string: app.debugDescription), named: "element-tree")
            return XCTFail("the app did not seed a throwaway store, so there is nothing to photograph — \(status)")
        }
    }

    private static var platform: String {
        #if os(macOS)
        "macOS"
        #elseif targetEnvironment(macCatalyst)
        "Mac Catalyst"
        #elseif os(visionOS)
        "visionOS"
        #else
        UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #endif
    }

    /// Which simulator this was, for a failure read days after the run's own log is gone.
    private static var device: String {
        ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "this machine"
    }

    #if os(macOS)
    /// Opens a window when the launch came up without one.
    ///
    /// `XCUIApplication.launch()` launches a Mac app in the *background*, and AppKit gives a
    /// background launch no window — it holds it until the user arrives. The app comes up as a menu
    /// bar and nothing else, every lookup in the walk comes back empty, and the run dies on the
    /// first wait with the seed sitting in a store no window is showing. `activate()` is not what
    /// AppKit waits for: only a reopen, the event a Dock icon click sends, builds the window, and a
    /// test runner has no way to send one — so the walk asks for the window itself, with the app's
    /// own New Window.
    ///
    /// Whether a launch gets away without this depends on who started the run: LaunchServices
    /// activates a launched app only while the process that launched it is frontmost, so the same
    /// walk comes up with a window when it is run by hand from a frontmost Terminal and with
    /// nothing but a menu bar when an agent runs it in the background.
    ///
    /// Waits first rather than counting windows straight after `launch()`, which returns on idle
    /// and can beat the window into the accessibility tree — ⌘N would then open a second, empty one
    /// and the walk would photograph that.
    private func openWindowIfNeeded() {
        if app.windows.firstMatch.waitForExistence(timeout: 10) { return }
        app.typeKey("n", modifierFlags: .command)
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 15),
                      "the app launched with no window and ⌘N opened none")
    }
    #endif

    // MARK: - Driving

    /// Tabs surface as different element types per platform — a tab is a `Button` on iOS, and a
    /// sidebar row on macOS, where the tab view is `.sidebarAdaptable` — so look through the types
    /// that can actually be activated rather than guessing one. `firstMatch` because iPadOS nests a
    /// tab's button inside another button with the same label, and tapping an ambiguous query fails.
    private func control(_ label: String) -> XCUIElement {
        for query in [app.buttons, app.radioButtons, app.descendants(matching: .tab)] {
            let element = query[label].firstMatch
            if element.exists { return element }
        }
        // A macOS sidebar row carries its title as the static text's *value*, which the subscripts
        // above cannot see; clicking that text hits the row.
        let row = text(label)
        if row.exists { return row }
        return app.buttons[label].firstMatch   // nothing matched; let the caller's assertion name the miss
    }

    /// Text addressed by whichever of the two the platform filled in. SwiftUI labels a `Text` on iOS
    /// and gives an AppKit static text a value instead, and the label subscript only reads the former.
    private func text(_ string: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "value == %@ OR label == %@", string, string)).firstMatch
    }

    private func activate(_ element: XCUIElement, _ description: String) {
        guard waitFor(element, description) else { return }
        #if os(macOS)
        element.click()
        #else
        element.tap()
        #endif
    }

    /// Waits for `element`, and on a miss names the platform, the device, what it was waiting for,
    /// the shot it was heading for (if given), and what the app reported it seeded — so a failure
    /// reads as more than "seeded content never appeared".
    @discardableResult
    private func waitFor(_ element: XCUIElement, _ description: String, shot: String? = nil, timeout: TimeInterval = 15) -> Bool {
        guard element.waitForExistence(timeout: timeout) else {
            attach(XCTAttachment(string: app.debugDescription), named: "element-tree")
            XCTFail("""
                never found \(description) on \(Self.platform), \(Self.device)\
                \(shot.map { ", heading for \($0)" } ?? ""). The app reported: \(seedStatus)
                """)
            return false
        }
        return true
    }

    /// Animations and async content have no element to wait on, so the shots pause instead. The
    /// summary's marquee counts up on a 1-second timeline, and its charts animate in behind it.
    private func settle(seconds: TimeInterval = 3) {
        Thread.sleep(forTimeInterval: seconds)
    }

    // MARK: - Capturing

    private func capture(_ name: String) {
        // Every capture below photographs the whole screen, or the frontmost window — never this
        // app in particular. So an app that has lost the foreground yields another app's UI, filed
        // under this app's name, at the right size, with nothing to notice. The shared runner holds
        // a machine-wide lock so that cannot happen; this is the check that it held.
        XCTAssertEqual(app.state, .runningForeground,
                       "\(name): the app under test was not frontmost — another app has this device")
        #if os(macOS)
        captureWindow(named: name)
        #else
        // The simulator's screen already *is* the store's canvas, at the exact required pixel size.
        attach(XCTAttachment(screenshot: XCUIScreen.main.screenshot()), named: name)
        #endif
    }

    private func attach(_ attachment: XCTAttachment, named name: String) {
        attachment.name = name
        attachment.lifetime = .keepAlways   // attachments on a passing test are discarded otherwise
        add(attachment)
    }

    #if os(macOS)

    /// Asks the shell running the tests to photograph the window, and waits for it.
    ///
    /// The good capture is `screencapture -l`, which reads the window's own buffer: correctly masked
    /// to the rounded corners, with real alpha and the system's own shadow. (`XCUIElement.screenshot()`
    /// crops the *screen* to the window's frame, so it loses the shadow — drawn outside that frame —
    /// and leaves desktop inside the corners.) But `screencapture` needs Screen Recording, which the
    /// test runner has no grant for and the terminal running `Scripts/screenshots.sh` does. So the
    /// test drives the UI and the script takes the picture.
    ///
    /// They meet in a plain directory under /tmp. That works only because the runner is deliberately
    /// unsandboxed (My AssetsUITests/My AssetsUITests.entitlements): a sandboxed runner cannot write
    /// /tmp, and its own container is unreadable to the script, so the two would have nowhere to meet.
    private static let handshakeDirectory = URL(fileURLWithPath: "/tmp/app-store-screenshots")

    private func captureWindow(named name: String) {
        let files = FileManager.default
        let handshake = Self.handshakeDirectory
        let done = handshake.appendingPathComponent("done-\(name)")
        try? files.removeItem(at: done)

        let request = handshake.appendingPathComponent("request-\(name)")
        guard files.createFile(atPath: request.path, contents: nil) else {
            return XCTFail("could not write a capture request to \(request.path)")
        }

        let deadline = Date().addingTimeInterval(30)
        while Date() < deadline {
            if files.fileExists(atPath: done.path) { return }
            Thread.sleep(forTimeInterval: 0.1)
        }
        XCTFail("timed out waiting for the script to capture \(name) — is Scripts/screenshots.sh watching \(handshake.path)?")
    }

    #endif
}
