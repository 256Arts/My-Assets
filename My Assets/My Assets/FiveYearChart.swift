//
//  FiveYearChart.swift
//  My Assets
//
//  Created by Jayden Irwin on 2023-09-01.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
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
    
    @Binding var chartDataSource: ChartDataSource
    
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
                value = data.netWorth(at: $0, passive: false)
            }
            return ValueAtDate(value: value, date: $0)
        }
    }
    var passiveNetWorthChartData: [ValueAtDate] {
        guard chartDataSource == .netWorth else { return [] }
        
        return nowThrough5Years.map {
            ValueAtDate(value: data.netWorth(at: $0, passive: true), date: $0)
        }
    }
    var chartInflationData: [ValueAtDate] {
        let startingValue: Double
        switch chartDataSource {
        case .balance:
            startingValue = data.balance(at: .now)
        case .netWorth:
            startingValue = data.netWorth(at: .now, passive: false)
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
            let total = data.avgAnnualNetWorthInterest(passive: false)
            let passive = data.avgAnnualNetWorthInterest(passive: true)
            if 0 < total {
                return Text("YoY: \(percentFormatter.string(from: NSNumber(value: total))!)\n") +
                    Text("Passive YoY: \(percentFormatter.string(from: NSNumber(value: passive))!)")
                    .foregroundStyle(.secondary)
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
                    .foregroundStyle(Color.green)
            }
            ForEach(passiveNetWorthChartData) { datum in
                LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Passive Net Worth"))
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(Color.secondary)
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
    FiveYearChart(chartDataSource: .constant(.balance))
}
