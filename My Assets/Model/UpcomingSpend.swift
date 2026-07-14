import Foundation
import SwiftData

protocol Schedulable {
    var name: String? { get }
    var amount: Double? { get }
    var nextTransactionDate: Date? { get }
}

@Model
final class UpcomingSpend: Schedulable, Hashable {
    
    var name: String?
    var cost: Double?
    var date: Date?
    var repeatYears: Int? // nil = one-shot purchase

    var amount: Double? {
        guard let cost else { return nil }

        return -cost
    }
    var nextTransactionDate: Date? {
        guard let date else { return nil }
        guard let repeatYears, 0 < repeatYears else { return date }

        let calendar = Calendar.autoupdatingCurrent
        var nextDate = date
        while nextDate.timeIntervalSince(calendar.startOfDay(for: .now)) < 0 {
            nextDate = calendar.date(byAdding: .year, value: repeatYears, to: nextDate)!
        }
        return nextDate
    }

    var asset: Asset?

    var monthlyCost: Double? {
        guard let nextTransactionDate, let cost, nextTransactionDate.timeIntervalSinceNow > 0 else { return nil }

        let monthsToDate = max(1, nextTransactionDate.timeIntervalSinceNow / TimeInterval.month)
        return cost / monthsToDate
    }
    var repeatDescription: String? {
        guard let repeatYears, 0 < repeatYears else { return nil }

        return repeatYears == 1 ? "Every year" : "Every \(repeatYears) years"
    }

    /// Total cost of purchases in (now, endDate]: `date`, then every `repeatYears` after.
    func totalCost(upTo endDate: Date) -> Double {
        guard let date, let cost else { return 0 }

        let calendar = Calendar.autoupdatingCurrent
        var occurrence = date
        var total = 0.0
        while occurrence <= endDate {
            if .now < occurrence { total += cost }
            guard let repeatYears, 0 < repeatYears else { break }
            occurrence = calendar.date(byAdding: .year, value: repeatYears, to: occurrence)!
        }
        return total
    }

    init(name: String = "", cost: Double = 0, date: Date = .now, asset: Asset? = nil, repeatYears: Int? = nil) {
        self.name = name
        self.cost = cost
        self.date = date
        self.asset = asset
        self.repeatYears = repeatYears
    }
    
}
