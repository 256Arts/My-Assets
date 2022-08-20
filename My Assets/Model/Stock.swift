//
//  Stock.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import Foundation

class Stock: Identifiable, Codable {
    
    static let apiKey = "MZ4NGAVYGGF4NACP"
    
    let symbol: String
    var id: String {
        symbol
    }
    var numberOfShares: Int
    var price: Double?
    var annualInterestFraction: Double? {
        guard let prevD = prevDate, let prevP = prevPrice, let curr = price else { return nil }
        let yearsSinceDate = Date().timeIntervalSince(prevD) / TimeInterval.year
        return ((prevP / curr) - 1) / yearsSinceDate
    }
    
    private var prevPrice: Double?
    private var prevDate: Date?
    
    init(symbol: String, shares: Int) {
        self.symbol = symbol
        self.numberOfShares = shares
        self.price = nil
        self.prevPrice = nil
        self.prevDate = nil
    }
    
    func fetchPrices() {
        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=\(symbol)&apikey=\(Stock.apiKey)")!
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print(error)
//                self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                print(response)
//                self.handleServerError(response)
                return
            }
            do {
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data, options: [])
                    as? [String: [String: Any]] else {
                    print("error trying to convert data to JSON")
                    return
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
                    print("this month key failed")
                    return
                }
                guard let thisMonthData = timeSeries[thisMonthKey], let aYearAgoData = timeSeries[aYearAgoKey] else {
                    print("this month data failed")
                    return
                }
                let closeKey = "4. close"
                guard let thisMonthCloseString = thisMonthData[closeKey], let aYearAgoCloseString = aYearAgoData[closeKey] else {
                    print("this month close string failed")
                    return
                }
                guard let thisMonthClose = Double(thisMonthCloseString), let aYearAgoClose = Double(aYearAgoCloseString) else {
                    print("this month close failed")
                    return
                }
                self?.price = thisMonthClose
                self?.prevPrice = aYearAgoClose
                df.dateFormat = "yyyy-MM-dd"
                self?.prevDate = df.date(from: aYearAgoKey)!
                CloudController.shared.financialData?.save()
                print(self?.price, self?.prevPrice)
            } catch {
                print("error")
            }
        }
        task.resume()
    }
    
    func fetchExchange() {
        let url = URL(string: "https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_MONTHLY&symbol=\(symbol)&market=USD&apikey=\(Stock.apiKey)")!
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
    //                self.handleClientError(error)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
    //                self.handleServerError(response)
                    return
                }
                do {
                    guard let data = data, let json = try JSONSerialization.jsonObject(with: data, options: [])
                        as? [String: [String: Any]] else {
                        print("error trying to convert data to JSON")
                        return
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
                        return
                    }
                    guard let thisMonthData = timeSeries[thisMonthKey], let aYearAgoData = timeSeries[aYearAgoKey] else {
                        return
                    }
                    let closeKey = "4b. close (USD)"
                    guard let thisMonthCloseString = thisMonthData[closeKey], let aYearAgoCloseString = aYearAgoData[closeKey] else {
                        return
                    }
                    guard let thisMonthClose = Double(thisMonthCloseString), let aYearAgoClose = Double(aYearAgoCloseString) else {
                        return
                    }
                    self?.price = thisMonthClose
                    self?.prevPrice = aYearAgoClose
                    df.dateFormat = "yyyy-MM-dd"
                    self?.prevDate = df.date(from: aYearAgoKey)!
                    CloudController.shared.financialData?.save()
                    print(self?.price, self?.prevPrice)
                } catch {
                    print("error")
                }
            }
            task.resume()
        }
    
}
