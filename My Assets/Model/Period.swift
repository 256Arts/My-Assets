import Foundation

enum Period: String, Identifiable, CaseIterable {
    
    case day = "Daily"
    case month = "Monthly"
    case year = "Yearly"
    
    var id: Self { self }
    var displayName: LocalizedStringResource {
        switch self {
        case .day:
            "Daily"
        case .month:
            "Monthly"
        case .year:
            "Yearly"
        }
    }
    var months: Double {
        switch self {
        case .day:
            return 1/30
        case .month:
            return 1
        case .year:
            return 12
        }
    }
}
