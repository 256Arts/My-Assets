//
//  SummaryView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2023-10-23.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftUI
import SwiftData
import Charts

struct SummaryView: View {
    
    @AppStorage(UserDefaults.Key.amountMarqueePeriod) var periodRawValue = "Month"
    @AppStorage(UserDefaults.Key.amountMarqueeShowAsCombinedValue) var showAsCombinedValue = false
    @AppStorage(UserDefaults.Key.summaryScreenShowBalance) var summaryScreenShowBalance = true
    @AppStorage(UserDefaults.Key.summaryScreenShowNetWorth) var summaryScreenShowNetWorth = true
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @State var showingSettings = false
    @State var showingNetWorthChartInfo = false
    @State var showingNetWorthPercentileInfo = false
    @State var period = Period(rawValue: UserDefaults.standard.string(forKey: UserDefaults.Key.amountMarqueePeriod) ?? "") ?? .month {
        didSet {
            periodRawValue = period.rawValue
        }
    }
    
    var insights: InsightsGenerator {
        .init(data: data)
    }
    
    var body: some View {
        NavigationStack {
            List {
                if summaryScreenShowBalance {
                    Section {
                        VStack(spacing: 22) {
                            TimelineView(.periodic(from: Date.now, by: 1.0)) { context in
                                AmountMarquee(period: $period, showAsCombinedValue: $showAsCombinedValue, currentValue: data.balance(at: context.date), monthlyIncome: data.totalLiquidIncome, monthlyExpenses: data.totalExpenses)
                            }
                            .contextMenu {
                                Picker("Period", selection: $period) {
                                    ForEach(Period.allCases) {
                                        Text($0.rawValue)
                                            .tag($0)
                                    }
                                }
                                Toggle("Show Combined Value", isOn: $showAsCombinedValue)
                            }
                            
                            FiveYearChart(chartDataSource: .balance)
                        }
                    } header: {
                        Text("Balance")
                    }
                }
                
                if summaryScreenShowNetWorth {
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
                            
                            FiveYearChart(chartDataSource: .netWorth)
                                .overlay(alignment: .bottomTrailing) {
                                    Button {
                                        showingNetWorthChartInfo = true
                                    } label: {
                                        Image(systemName: "info.circle")
                                    }
                                    .buttonStyle(.borderless)
                                }
                            
                            if let netWorthPercentile = insights.netWorthPercentile() {
                                HStack {
                                    Gauge(value: netWorthPercentile) {
                                        Text("Net Worth Percentile")
                                    } currentValueLabel: {
                                        Text(insights.netWorthPercentileString ?? "")
                                    }
                                    .gaugeStyle(.accessoryLinear)
                                    .tint(LinearGradient(colors: [.red, .gray, .green], startPoint: .leading, endPoint: .trailing))
                                    .accessibilityHidden(true)
                                    
                                    Button {
                                        showingNetWorthPercentileInfo = true
                                    } label: {
                                        Image(systemName: "info.circle")
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                    } header: {
                        Text("Net Worth")
                    }
                }
                
                Section {
                    ForEach(Array(insights.generate().enumerated()), id: \.0) { (_, string) in
                        Text(string)
                    }
                } header: {
                    Text("Insights")
                }
            }
            .headerProminence(.increased)
            .navigationTitle("Summary")
            .toolbar {
                #if !os(macOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                #endif
            }
        }
        .alert("Net Worth Percentile", isPresented: $showingNetWorthPercentileInfo, actions: {
            Button("OK") { }
        }, message: {
            Text("Net worth percentiles are based on 2023 data from the USA, adjusted for inflation, and converted to your currency.")
        })
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .sheet(isPresented: $showingNetWorthChartInfo) {
            NavigationStack {
                NetWorthChartInfoView()
            }
        }
    }
}

#Preview {
    SummaryView()
}
