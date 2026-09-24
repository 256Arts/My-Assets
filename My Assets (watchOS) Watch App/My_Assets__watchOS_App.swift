import SwiftUI
import SwiftData

@main
struct My_Assets__watchOS__Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .screenshotModeStatus()
        }
        .modelContainer(sharedModelContainer)
    }
}

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter
}()

let timeRemainingFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.maximumUnitCount = 1
    formatter.allowedUnits = [.day, .month, .year]
    return formatter
}()
