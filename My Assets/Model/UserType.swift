import Foundation

enum UserType: String, Identifiable, CaseIterable {
    case individual = "Individual"
    case household = "Household"
    
    var id: Self { self }
}
