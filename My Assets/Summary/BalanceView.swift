//
//  BalanceView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2024-08-11.
//  Copyright © 2024 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct BalanceView: View {
    
    @AppStorage(UserDefaults.Key.amountMarqueePeriod) var periodRawValue = "Month"
    @AppStorage(UserDefaults.Key.amountMarqueeShowAsCombinedValue) var showAsCombinedValue = false
    @AppStorage(UserDefaults.Key.summaryScreenBalanceShowChart) var summaryScreenBalanceShowChart = true
    
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
            
            Section {
                FiveYearChart(chartDataSource: .balance)
                
                Toggle("Show in Summary", isOn: $summaryScreenBalanceShowChart)
            } header: {
                Text("Graph")
            }
        }
        .navigationTitle("Balance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    BalanceView()
}
