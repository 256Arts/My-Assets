//
//  Period.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2021-10-26.
//  Copyright © 2021 256 Arts Developer. All rights reserved.
//

import Foundation

enum Period: String, Identifiable, CaseIterable {
    
    case day = "Daily"
    case month = "Monthly"
    case year = "Yearly"
    
    var id: Self { self }
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
