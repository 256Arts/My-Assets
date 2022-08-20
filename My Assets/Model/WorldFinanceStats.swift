//
//  WorldFinanceStats.swift
//  My Assets
//
//  Created by Jayden Irwin on 2022-04-09.
//  Copyright © 2022 Jayden Irwin. All rights reserved.
//

import Foundation

final class WorldFinanceStats {
    
    struct Bracket: Equatable {
        let percentile: Double
        let money: Double
    }
    
    static let shared = WorldFinanceStats()
    
    let averageAnnualUSInflation = 0.03
    
    let conversionRates = [
        "USD": 1.0,
        "CAD": 0.79
    ]
    
    func usHouseholdNetWorthPercentiles(at date: Date) -> [Bracket] {
        let percentiles2020: [Bracket] = [
            Bracket(percentile: 0.01, money: -100_000),
            Bracket(percentile: 0.10, money: -500),
            Bracket(percentile: 0.20, money: 6000),
            Bracket(percentile: 0.30, money: 24_000),
            Bracket(percentile: 0.40, money: 67_000),
            Bracket(percentile: 0.50, money: 120_000),
            Bracket(percentile: 0.60, money: 201_000),
            Bracket(percentile: 0.70, money: 315_000),
            Bracket(percentile: 0.80, money: 560_000),
            Bracket(percentile: 0.90, money: 1_120_000),
            Bracket(percentile: 0.99, money: 11_100_000)
        ]
        return percentiles2020.map {
            guard let dataYear = Calendar.current.date(from: DateComponents(year: 2020)) else { return $0 }
            let yearsSinceDate = date.timeIntervalSince(dataYear) / TimeInterval.year
            return Bracket(percentile: $0.percentile, money: $0.money * pow(1 + averageAnnualUSInflation, yearsSinceDate))
        }
    }
    
    func adjustForInflation(value: Double, in futureDate: Date) -> Double {
        let yearsToDate = futureDate.timeIntervalSinceNow / .year
        return value * pow(1 - averageAnnualUSInflation, yearsToDate)
    }
    
}
