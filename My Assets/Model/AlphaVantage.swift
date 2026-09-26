import Foundation

final actor AlphaVantage {

    enum QueryError: Error {
        case badStatusCode
        case failedToDecode
        /// Alpha Vantage returns HTTP 200 with a `Note` or `Information` body when the API rate limit is hit.
        case rateLimited(String)
        case apiError(String)
        case timeSeriesNotFound
        case monthKeyNotFound
        case monthDataNotFound
        case monthCloseNotFound
        case monthCloseNotDouble
    }

    static let shared = AlphaVantage()

    func fetchPrices(symbol: String) async throws -> (price: Double, prevPrice: Double, prevDate: Date) {
        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=\(symbol)&apikey=\(Secrets.alphaVantageKey)")!
        return try await fetchMonthlyCloses(url: url, timeSeriesKey: "Monthly Time Series", closeKey: "4. close")
    }

    func fetchExchange(from symbol: String, to market: String) async throws -> (price: Double, prevPrice: Double, prevDate: Date) {
        let url = URL(string: "https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_MONTHLY&symbol=\(symbol)&market=\(market)&apikey=\(Secrets.alphaVantageKey)")!
        return try await fetchMonthlyCloses(url: url, timeSeriesKey: "Time Series (Digital Currency Monthly)", closeKey: "4b. close (USD)")
    }

    private func fetchMonthlyCloses(url: URL, timeSeriesKey: String, closeKey: String) async throws -> (price: Double, prevPrice: Double, prevDate: Date) {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
            throw QueryError.badStatusCode
        }
        return try Self.parseMonthlyCloses(data: data, timeSeriesKey: timeSeriesKey, closeKey: closeKey)
    }

    static func parseMonthlyCloses(data: Data, timeSeriesKey: String, closeKey: String, now: Date = Date()) throws -> (price: Double, prevPrice: Double, prevDate: Date) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw QueryError.failedToDecode
        }
        if let message = (json["Note"] ?? json["Information"]) as? String {
            throw QueryError.rateLimited(message)
        }
        if let message = json["Error Message"] as? String {
            throw QueryError.apiError(message)
        }
        guard let timeSeries = json[timeSeriesKey] as? [String: [String: String]] else {
            throw QueryError.timeSeriesNotFound
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.calendar = calendar
        df.timeZone = calendar.timeZone
        df.dateFormat = "yyyy-MM"
        let thisMonthString = df.string(from: now)
        guard let aYearAgo = calendar.date(byAdding: .year, value: -1, to: now) else {
            throw QueryError.monthKeyNotFound
        }
        let aYearAgoString = df.string(from: aYearAgo)

        guard let thisMonthKey = timeSeries.keys.first(where: { $0.hasPrefix(thisMonthString) }), let aYearAgoKey = timeSeries.keys.first(where: { $0.hasPrefix(aYearAgoString) }) else {
            throw QueryError.monthKeyNotFound
        }
        guard let thisMonthData = timeSeries[thisMonthKey], let aYearAgoData = timeSeries[aYearAgoKey] else {
            throw QueryError.monthDataNotFound
        }
        guard let thisMonthCloseString = thisMonthData[closeKey], let aYearAgoCloseString = aYearAgoData[closeKey] else {
            throw QueryError.monthCloseNotFound
        }
        guard let thisMonthClose = Double(thisMonthCloseString), let aYearAgoClose = Double(aYearAgoCloseString) else {
            throw QueryError.monthCloseNotDouble
        }
        df.dateFormat = "yyyy-MM-dd"
        guard let prevDate = df.date(from: aYearAgoKey) else {
            throw QueryError.monthKeyNotFound
        }
        return (thisMonthClose, aYearAgoClose, prevDate)
    }

}
