//
//  TransactionFrequency.swift
//  My Assets
//
//  Created by Jayden Irwin on 2024-08-26.
//  Copyright © 2024 Jayden Irwin. All rights reserved.
//

import Foundation

enum TransactionFrequency: String, CaseIterable, Codable, Identifiable {
    case weekly
    case biweekly
    case bimonthly
    case monthly
    
    var id: Self { self }
    
    var timesPerMonth: Double {
        switch self {
        case .weekly:
            30.5 / 7
        case .biweekly:
            30.5 / 14
        case .bimonthly:
            2
        case .monthly:
            1
        }
    }
    
    var calendarValues: (Calendar.Component, Int) {
        switch self {
        case .weekly:
            (.weekOfYear, 1)
        case .biweekly:
            (.weekOfYear, 2)
        case .bimonthly:
            (.day, 15)
        case .monthly:
            (.month, 1)
        }
    }
}
