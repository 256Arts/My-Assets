//
//  NetWorthView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2023-10-28.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct NetWorthView: View {
    
    @AppStorage(UserDefaults.Key.amountMarqueePeriod) var periodRawValue = "Month"
    @AppStorage(UserDefaults.Key.amountMarqueeShowAsCombinedValue) var showAsCombinedValue = false
    @AppStorage(UserDefaults.Key.summaryScreenNetWorthShowChart) var summaryScreenNetWorthShowChart = true
    @AppStorage(UserDefaults.Key.summaryScreenNetWorthShowPercentile) var summaryScreenNetWorthShowPercentile = true
    
    @EnvironmentObject var data: FinancialData
    @Environment(\.dismiss) private var dismiss
    
    @State var period = Period(rawValue: UserDefaults.standard.string(forKey: UserDefaults.Key.amountMarqueePeriod) ?? "") ?? .month {
        didSet {
            periodRawValue = period.rawValue
        }
    }
    
    var insights: InsightsGenerator {
        .init(data: data)
    }
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 22) {
                    TimelineView(.periodic(from: Date.now, by: 1.0)) { context in
                        AmountMarquee(period: $period, showAsCombinedValue: $showAsCombinedValue, currentValue: data.netWorth(at: context.date, type: .working), monthlyIncome: data.totalIncome, monthlyExpenses: data.totalExpenses)
                    }
                    .contextMenu {
                        Picker("Period", selection: $period) {
                            ForEach(Period.allCases) {
                                Text($0.rawValue)
                                    .tag($0)
                            }
                        }
                        Toggle("Show as Combined", isOn: $showAsCombinedValue)
                    }
                }
            }
            
            Section {
                FiveYearChart(chartDataSource: .netWorth)
                    .padding(.top, 6)
                
                Toggle("Show in Summary", isOn: $summaryScreenNetWorthShowChart)
                
                chartLineDescription(color: .blue, title: "Net Worth", description: "Standard net worth calculation.", income: data.totalIncome, expenses: data.totalExpenses)
                
                if data.totalIncome != data.totalPassiveIncome {
                    if data.totalExpenses != data.totalPassiveExpenses {
                        chartLineDescription(color: .green, title: "Natural", description: "Only assets, debts, and interest on them. (No human interaction. No work income, or living expenses.)", income: data.totalPassiveIncome, expenses: data.totalPassiveExpenses)
                    }
                    
                    chartLineDescription(color: .orange, title: "Unemployed", description: "Net worth with only passive income.", income: data.totalPassiveIncome, expenses: data.totalExpenses)
                }
            } header: {
                Text("Graph")
            }
            
            if let netWorthPercentile = insights.netWorthPercentile() {
                Section {
                    Gauge(value: netWorthPercentile) {
                        Text("Percentile")
                    } currentValueLabel: {
                        Text(insights.netWorthPercentileString ?? "")
                    }
                    .gaugeStyle(.accessoryLinear)
                    .tint(LinearGradient(colors: [.red, .gray, .green], startPoint: .leading, endPoint: .trailing))
                    .accessibilityHidden(true)
                    
                    Toggle("Show in Summary", isOn: $summaryScreenNetWorthShowPercentile)
                } header: {
                    Text("Percentile")
                } footer: {
                    Text("Based on 2023 data from the USA, adjusted for inflation, and converted to your currency.")
                }
            }
        }
        .navigationTitle("Net Worth")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func chartLineDescription(color: Color, title: String, description: String, income: Double, expenses: Double) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                chartLineIncomeAndExpenses(income: income, expenses: expenses)
            }
        } icon: {
            Image(systemName: "circle")
                .symbolVariant(.fill)
                .imageScale(.small)
                .foregroundStyle(color)
        }
    }
    
    @ViewBuilder
    private func chartLineIncomeAndExpenses(income: Double, expenses: Double) -> some View {
        HStack {
            Text(currencyDeltaFormatter.string(from: NSNumber(value: income))!)
                .foregroundColor(.green)
                .accessibilityLabel("Income")
            Text(currencyDeltaFormatter.string(from: NSNumber(value: -expenses))!)
                .foregroundColor(.red)
                .accessibilityLabel("Expenses")
        }
        .font(.footnote)
    }
}

#Preview {
    NetWorthView()
}
