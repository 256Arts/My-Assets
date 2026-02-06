//
//  LongTermChart.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2023-09-01.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftUI
import Charts

struct LongTermChart: View {
    
    enum ChartDataSource: String, Identifiable, CaseIterable {
        case balance = "Balance"
        case netWorth = "Net Worth"
        
        var id: Self { self }
    }
    enum ChartStyle: String, Identifiable, CaseIterable {
        case trajectories = "Trajectories"
        case assetsVSDebts = "Assets/Debts"
        
        var id: Self { self }
    }
    struct ValueAtDate: Identifiable {
        let value: Double
        let date: Date
        var id: Date { date }
    }
    
    @Environment(FinancialData.self) private var data
    @Binding var years: Int
    @Binding var chartStyle: ChartStyle
    
    let chartDataSource: ChartDataSource
    
    var dates: [Date] {
        (0...years).map { Date.now + TimeInterval($0) * .year }
    }
    var insights: InsightsGenerator {
        .init(data: data)
    }
    
    var chartData: [ValueAtDate] {
        dates.map {
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
        
        return dates.map {
            ValueAtDate(value: data.netWorth(at: $0, type: .natural), date: $0)
        }
    }
    var notWorkingNetWorthChartData: [ValueAtDate] {
        guard chartDataSource == .netWorth else { return [] }
        
        return dates.map {
            ValueAtDate(value: data.netWorth(at: $0, type: .notWorking), date: $0)
        }
    }
    var assetsChartData: [ValueAtDate] {
        dates.map {
            ValueAtDate(value: data.netWorthComponents(at: $0, type: .working).assets, date: $0)
        }
    }
    var debtsChartData: [ValueAtDate] {
        dates.map {
            ValueAtDate(value: -data.netWorthComponents(at: $0, type: .working).debts, date: $0)
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
        let nowThroughYears = (0...years)
        return nowThroughYears.map {
            let value = startingValue * pow(1 + WorldFinanceStats.averageAnnualUSInflation, Double($0))
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
            
            switch chartStyle {
            case .trajectories:
                if data.totalIncome != data.totalPassiveIncome {
                    if data.totalExpenses != data.totalPassiveExpenses {
                        ForEach(passiveAssetsAndDebtsNetWorthChartData) { datum in
                            LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Natural"))
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(by: .value("Data", "Natural"))
                        }
                    }
                    
                    ForEach(notWorkingNetWorthChartData) { datum in
                        LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Unemployed"))
                            .interpolationMethod(.cardinal)
                            .foregroundStyle(by: .value("Data", "Unemployed"))
                    }
                }
            case .assetsVSDebts:
                ForEach(assetsChartData) { datum in
                    AreaMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Assets"))
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(Color.green.opacity(0.25))
                    LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Assets"))
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(Color.green)
                }
                
                ForEach(debtsChartData) { datum in
                    AreaMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Debts"))
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(Color.red.opacity(0.25))
                    LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Debts"))
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(Color.red)
                }
            }
            
            ForEach(chartInflationData) { datum in
                LineMark(x: .value("Date", datum.date), y: .value("Value", datum.value), series: .value("Data", "Inflation"))
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.01, 4]))
            }
        }
        .chartYAxis {
            AxisMarks(format: .currency(code: Locale.autoupdatingCurrent.currency?.identifier ?? "USD").notation(.compactName))
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
    LongTermChart(years: .constant(5), chartStyle: .constant(.trajectories), chartDataSource: .balance)
}
