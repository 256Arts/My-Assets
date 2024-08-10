//
//  UpcomingSpend.swift
//  My Assets
//
//  Created by Jayden Irwin on 2024-01-02.
//  Copyright © 2024 Jayden Irwin. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class UpcomingSpend: Hashable {
    
    var name: String?
    var cost: Double?
    var date: Date?
    
    var asset: Asset?
    
    var monthlyCost: Double? {
        guard let date, let cost, date.timeIntervalSinceNow > 0 else { return nil }
        
        let monthsToDate = max(1, date.timeIntervalSinceNow / TimeInterval.month)
        return cost / monthsToDate
    }
    
    init(name: String = "", cost: Double = 0, date: Date = .now, asset: Asset? = nil) {
        self.name = name
        self.cost = cost
        self.date = date
        self.asset = asset
    }
    
}
