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
    
    enum Subpage: Identifiable {
        case balance, netWorth
        
        var id: Self { self }
    }
    
    @AppStorage(UserDefaults.Key.amountMarqueePeriod) var periodRawValue = "Month"
    @AppStorage(UserDefaults.Key.amountMarqueeShowAsCombinedValue) var showAsCombinedValue = false
    @AppStorage(UserDefaults.Key.summaryScreenShowBalance) var summaryScreenShowBalance = true
    @AppStorage(UserDefaults.Key.summaryScreenBalanceShowChart) var summaryScreenBalanceShowChart = true
    @AppStorage(UserDefaults.Key.summaryScreenShowNetWorth) var summaryScreenShowNetWorth = true
    @AppStorage(UserDefaults.Key.summaryScreenNetWorthShowChart) var summaryScreenNetWorthShowChart = true
    @AppStorage(UserDefaults.Key.summaryScreenNetWorthShowPercentile) var summaryScreenNetWorthShowPercentile = true
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @State var showingSettings = false
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
                    Section("Balance") {
                        NavigationLink(value: Subpage.balance) {
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
                                
                                if summaryScreenBalanceShowChart {
                                    FiveYearChart(chartDataSource: .balance)
                                }
                            }
                        }
                    }
                }
                
                if summaryScreenShowNetWorth {
                    Section("Net Worth") {
                        NavigationLink(value: Subpage.netWorth) {
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
                                
                                if summaryScreenNetWorthShowChart {
                                    FiveYearChart(chartDataSource: .netWorth)
                                }
                                
                                if summaryScreenNetWorthShowPercentile, let netWorthPercentile = insights.netWorthPercentile() {
                                    Gauge(value: netWorthPercentile) {
                                        Text("Net Worth Percentile")
                                    } currentValueLabel: {
                                        Text(insights.netWorthPercentileString ?? "")
                                    }
                                    .gaugeStyle(.accessoryLinear)
                                    .tint(LinearGradient(colors: [.red, .gray, .green], startPoint: .leading, endPoint: .trailing))
                                    .accessibilityHidden(true)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                
                Section("Insights") {
                    ForEach(Array(insights.generate().enumerated()), id: \.0) { (_, string) in
                        Text(string)
                    }
                }
                
                Section("Cash Flows") {
                    CashFlowsView()
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
            .navigationDestination(for: Subpage.self) { subpage in
                switch subpage {
                case .balance:
                    BalanceView()
                case .netWorth:
                    NetWorthView()
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}

#Preview {
    SummaryView()
}
