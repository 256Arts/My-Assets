import SwiftUI
import SwiftData

@main
struct My_Assets__watchOS__Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        #if targetEnvironment(simulator)
        .modelContainer(previewContainer)
        #else
        .modelContainer(for: [Asset.self, Debt.self, Stock.self, UpcomingSpend.self, Income.self, Expense.self, CreditCard.self])
        #endif
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
