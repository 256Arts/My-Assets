//
//  BalanceView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2024-08-11.
//  Copyright © 2024 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct BalanceView: View {
    
    @AppStorage(UserDefaults.Key.amountMarqueePeriod) var periodRawValue = "Month"
    @AppStorage(UserDefaults.Key.amountMarqueeShowAsCombinedValue) var showAsCombinedValue = false
    @AppStorage(UserDefaults.Key.summaryScreenBalanceShowChart) var summaryScreenBalanceShowChart = true
    
    @Environment(FinancialData.self) private var data
    @Environment(\.dismiss) private var dismiss
    
    @State var period = Period(rawValue: UserDefaults.standard.string(forKey: UserDefaults.Key.amountMarqueePeriod) ?? "") ?? .month {
        didSet {
            periodRawValue = period.rawValue
        }
    }
    @State var chartYears = 5
    
    var insights: InsightsGenerator {
        .init(data: data)
    }
    
    var body: some View {
        List {
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
                        Toggle("Show as Combined", isOn: $showAsCombinedValue)
                    }
                }
            }
            
            Section("Graph") {
                LongTermChart(years: $chartYears, chartStyle: .constant(.trajectories), chartDataSource: .balance)
                
                Picker("Period", selection: $chartYears) {
                    Text("2Y").tag(2)
                    Text("5Y").tag(5)
                    Text("10Y").tag(10)
                    Text("20Y").tag(20)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                
                Toggle("Show in Summary", isOn: $summaryScreenBalanceShowChart)
            }
        }
        .navigationTitle("Balance")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    BalanceView()
}
