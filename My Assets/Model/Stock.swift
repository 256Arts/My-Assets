//
//  Stock.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Stock {
    
    var symbol: String?
    var id: String {
        symbol ?? ""
    }
    var quantity: Double?
    var price: Double?
    var annualInterestFraction: Double? {
        guard let prevD = prevDate, let prevP = prevPrice, let curr = price else { return nil }
        let yearsSinceDate = Date().timeIntervalSince(prevD) / TimeInterval.year
        return ((prevP / curr) - 1) / yearsSinceDate
    }
    
    private var prevPrice: Double?
    private var prevDate: Date?
    
    init(symbol: String, quantity: Double) {
        self.symbol = symbol
        self.quantity = quantity
        self.price = nil
        self.prevPrice = nil
        self.prevDate = nil
    }
    
    func fetchPrices() async throws {
        guard let symbol else { return }
        
        let result = try await AlphaVantage.shared.fetchPrices(symbol: symbol)
        price = result.price
        prevPrice = result.prevPrice
        prevDate = result.prevDate
    }
    
    func fetchExchange() async throws {
        guard let symbol else { return }
        
        let result = try await AlphaVantage.shared.fetchExchange(from: symbol, to: Locale.current.currency?.identifier ?? "USD")
        price = result.price
        prevPrice = result.prevPrice
        prevDate = result.prevDate
    }
    
}
