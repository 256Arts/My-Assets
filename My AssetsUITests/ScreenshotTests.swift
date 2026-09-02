import XCTest

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

        // Assets is where the seed is most obviously present, so prove it landed before shooting.
        activate(control("Assets/Debts"), "Assets/Debts tab")
        // Rows read as "House, $500,000.00" — the row's amount is part of its label, so match the name.
        let houseRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "House")).firstMatch
        XCTAssertTrue(houseRow.waitForExistence(timeout: 30), "seeded content never appeared")
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

    // MARK: - Driving

    /// Tabs surface as different element types per platform — a tab is a `Button` on iOS, and a
    /// sidebar row on macOS, where the tab view is `.sidebarAdaptable` — so look through the types
    /// that can actually be activated rather than guessing one.
    private func control(_ label: String) -> XCUIElement {
        for query in [app.buttons, app.radioButtons, app.descendants(matching: .tab)] {
            let element = query[label]
            if element.exists { return element }
        }
        // A macOS sidebar row carries its title as the static text's *value*, which the subscripts
        // above cannot see; clicking that text hits the row.
        let row = text(label)
        if row.exists { return row }
        return app.buttons[label]   // nothing matched; let the caller's assertion name the miss
    }

    /// Text addressed by whichever of the two the platform filled in. SwiftUI labels a `Text` on iOS
    /// and gives an AppKit static text a value instead, and the label subscript only reads the former.
    private func text(_ string: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "value == %@ OR label == %@", string, string)).firstMatch
    }

    private func activate(_ element: XCUIElement, _ description: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 15), "never found \(description)")
        #if os(macOS)
        element.click()
        #else
        element.tap()
        #endif
    }

    /// Animations and async content have no element to wait on, so the shots pause instead. The
    /// summary's marquee counts up on a 1-second timeline, and its charts animate in behind it.
    private func settle(seconds: TimeInterval = 3) {
        Thread.sleep(forTimeInterval: seconds)
    }

    // MARK: - Capturing

    private func capture(_ name: String) {
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
