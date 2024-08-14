//
//  AlphaVantage.swift
//  My Assets
//
//  Created by Jayden Irwin on 2024-08-14.
//  Copyright © 2024 Jayden Irwin. All rights reserved.
//

import Foundation

final actor AlphaVantage {
    
    enum QueryError: Error {
        case badStatusCode
        case failedToDecode
        case monthKeyNotFound
        case monthDataNotFound
        case monthCloseNotFound
        case monthCloseNotDouble
    }
    
    static let shared = AlphaVantage()
    
    func fetchPrices(symbol: String) async throws -> (price: Double, prevPrice: Double, prevDate: Date) {
        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=\(symbol)&apikey=\(Secrets.alphaVantageKey)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
            throw QueryError.badStatusCode
        }
        guard let json = try JSONSerialization.jsonObject(with: data, options: [])
            as? [String: [String: Any]] else {
            throw QueryError.failedToDecode
        }
        let timeSeries = json["Monthly Time Series"] as! [String: [String: String]]
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        let thisMonthString = df.string(from: Date())
        let aYearAgoString: String = {
            let year = DateComponents(year: -1)
            return df.string(from: Calendar.current.date(byAdding: year, to: Date())!)
        }()
        
        guard let thisMonthKey = timeSeries.keys.first(where: { $0.contains(thisMonthString) }), let aYearAgoKey = timeSeries.keys.first(where: { $0.contains(aYearAgoString) }) else {
            throw QueryError.monthKeyNotFound
        }
        guard let thisMonthData = timeSeries[thisMonthKey], let aYearAgoData = timeSeries[aYearAgoKey] else {
            throw QueryError.monthDataNotFound
        }
        let closeKey = "4. close"
        guard let thisMonthCloseString = thisMonthData[closeKey], let aYearAgoCloseString = aYearAgoData[closeKey] else {
            throw QueryError.monthCloseNotFound
        }
        guard let thisMonthClose = Double(thisMonthCloseString), let aYearAgoClose = Double(aYearAgoCloseString) else {
            throw QueryError.monthCloseNotDouble
        }
        df.dateFormat = "yyyy-MM-dd"
        let prevDate = df.date(from: aYearAgoKey)!
        return (thisMonthClose, aYearAgoClose, prevDate)
    }
    
    func fetchExchange(from symbol: String, to market: String) async throws -> (price: Double, prevPrice: Double, prevDate: Date) {
        let url = URL(string: "https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_MONTHLY&symbol=\(symbol)&market=\(market)&apikey=\(Secrets.alphaVantageKey)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw QueryError.badStatusCode
        }
        guard let json = try JSONSerialization.jsonObject(with: data, options: [])
                as? [String: [String: Any]] else {
            throw QueryError.failedToDecode
        }
        let timeSeries = json["Time Series (Digital Currency Monthly)"] as! [String: [String: String]]
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        let thisMonthString = df.string(from: Date())
        let aYearAgoString: String = {
            let year = DateComponents(year: -1)
            return df.string(from: Calendar.current.date(byAdding: year, to: Date())!)
        }()
        
        guard let thisMonthKey = timeSeries.keys.first(where: { $0.contains(thisMonthString) }), let aYearAgoKey = timeSeries.keys.first(where: { $0.contains(aYearAgoString) }) else {
            throw QueryError.monthKeyNotFound
        }
        guard let thisMonthData = timeSeries[thisMonthKey], let aYearAgoData = timeSeries[aYearAgoKey] else {
            throw QueryError.monthDataNotFound
        }
        let closeKey = "4b. close (USD)"
        guard let thisMonthCloseString = thisMonthData[closeKey], let aYearAgoCloseString = aYearAgoData[closeKey] else {
            throw QueryError.monthCloseNotFound
        }
        guard let thisMonthClose = Double(thisMonthCloseString), let aYearAgoClose = Double(aYearAgoCloseString) else {
            throw QueryError.monthCloseNotDouble
        }
        df.dateFormat = "yyyy-MM-dd"
        let prevDate = df.date(from: aYearAgoKey)!
        return (thisMonthClose, aYearAgoClose, prevDate)
    }
    
}
