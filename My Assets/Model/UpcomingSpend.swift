//
//  UpcomingSpend.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2024-01-02.
//  Copyright © 2024 256 Arts Developer. All rights reserved.
//

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
    
    var amount: Double? {
        guard let cost else { return nil }
        
        return -cost
    }
    var nextTransactionDate: Date? { date }
    
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
