//
//  FiveYearChart.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2023-09-01.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftUI
import Charts

struct FiveYearChart: View {
    
    enum ChartDataSource: String, Identifiable, CaseIterable {
        case balance = "Balance"
        case netWorth = "Net Worth"
        
        var id: Self { self }
    }
    struct ValueAtDate: Identifiable {
        let value: Double
        let date: Date
        var id: Date { date }
    }
    
    @EnvironmentObject var data: FinancialData
    
    let nowThrough5Years = (0...5).map { Date.now + TimeInterval($0) * .year }
    let chartDataSource: ChartDataSource
    
    var insights: InsightsGenerator {
        .init(data: data)
    }
    
    var chartData: [ValueAtDate] {
        nowThrough5Years.map {
            let value: Double
            switch chartDataSource {
            case .balance:
                value = data.balance(at: $0)
            case .netWorth:
                value = data.netWorth(at: $0, type: .working)
            }
            return ValueAtDate(value: value, date: $0)
        }
    }
    var passiveAssetsAndDebtsNetWorthChartData: [ValueAtDate] {
        guard chartDataSource == .netWorth else { return [] }
        
        return nowThrough5Years.map {
            ValueAtDate(value: data.netWorth(at: $0, type: .natural), date: $0)
        }
    }
    var notWorkingNetWorthChartData: [ValueAtDate] {
        guard chartDataSource == .netWorth else { return [] }
        
        return nowThrough5Years.map {
            ValueAtDate(value: data.netWorth(at: $0, type: .notWorking), date: $0)
        }
    }
    var chartInflationData: [ValueAtDate] {
        let startingValue: Double
        switch chartDataSource {
        case .balance:
            startingValue = data.balance(at: .now)
        case .netWorth:
            startingValue = data.netWorth(at: .now, type: .working)
        }
        let nowThrough5Years = (0...5)
        return nowThrough5Years.map {
            let value = startingValue * pow(1 + WorldFinanceStats.shared.averageAnnualUSInflation, Double($0))
            let date = Date.now + TimeInterval($0) * .year
            return ValueAtDate(value: value, date: date)
        }
    }
    var chartYoYString: Text? {
        switch chartDataSource {
        case .balance:
            let fraction = insights.avgAnnualBalanceInterest
            if 0 < fraction {
                return Text("YoY: \(percentFormatter.string(from: NSNumber(value: fraction))!)")
            } else {
                return nil
            }
        case .netWorth:
            let fraction = data.avgAnnualNetWorthInterest
            if 0 < fraction {
                return Text("YoY: \(percentFormatter.string(from: NSNumber(value: fraction))!)")
            } else {
                return nil
            }
        }
    }
    
    var body: some View {
        Chart {
            ForEach(chartData) { datum in
                LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", chartDataSource.rawValue))
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(by: .value("Data", chartDataSource.rawValue))
            }
            if data.totalIncome != data.totalPassiveIncome {
                if data.totalExpenses != data.totalPassiveExpenses {
                    ForEach(passiveAssetsAndDebtsNetWorthChartData) { datum in
                        LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Natural"))
                            .interpolationMethod(.cardinal)
                            .foregroundStyle(by: .value("Data", "Natural"))
                    }
                }
                ForEach(notWorkingNetWorthChartData) { datum in
                    LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Quit Working"))
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(by: .value("Data", "Quit Working"))
                }
            }
            ForEach(chartInflationData) { datum in
                LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Inflation"))
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.01, 4]))
            }
        }
        .frame(height: 200)
        .overlay(alignment: .topLeading) {
            if let chartYoYString {
                chartYoYString
                    .font(.headline)
            }
        }
    }
}

#Preview {
    FiveYearChart(chartDataSource: .balance)
}
