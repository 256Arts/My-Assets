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
    @AppStorage(UserDefaults.Key.summaryScreenShowCashFlows) var summaryScreenShowCashFlows = true
    @AppStorage(UserDefaults.Key.summaryScreenShowInsights) var summaryScreenShowInsights = true
    
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
                                
                                if summaryScreenBalanceShowChart, !data.balance(at: .now).isZero {
                                    LongTermChart(years: .constant(5), chartStyle: .constant(.trajectories), chartDataSource: .balance)
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
                                
                                if summaryScreenNetWorthShowChart, !data.netWorth(at: .now, type: .working).isZero {
                                    LongTermChart(years: .constant(5), chartStyle: .constant(.trajectories), chartDataSource: .netWorth)
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
                
                if summaryScreenShowCashFlows {
                    Section("Cash Flows") {
                        CashFlowsView()
                    }
                }
                
                if summaryScreenShowInsights {
                    Section("Insights") {
                        ForEach(Array(insights.generate().enumerated()), id: \.0) { (_, string) in
                            Text(string)
                        }
                    }
                }
            }
            .headerProminence(.increased)
            .navigationTitle("Summary")
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Section {
                        Toggle("Show Balance", isOn: $summaryScreenShowBalance)
                        Toggle("Show Net Worth", isOn: $summaryScreenShowNetWorth)
                        Toggle("Show Cash Flows", isOn: $summaryScreenShowCashFlows)
                        Toggle("Show Insights", isOn: $summaryScreenShowInsights)
                    }
                    
                    Button("Settings", systemImage: "gear") {
                        showingSettings = true
                    }
                    
                    Section {
                        Link(destination: URL(string: "https://www.256arts.com/")!) {
                            Label("Developer Website", systemImage: "safari")
                        }
                        Link(destination: URL(string: "https://www.256arts.com/joincommunity/")!) {
                            Label("Join Community", systemImage: "bubble.left.and.bubble.right")
                        }
                        Link(destination: URL(string: "https://github.com/256Arts/My-Assets")!) {
                            Label("Contribute on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        }
                    }
                }
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
