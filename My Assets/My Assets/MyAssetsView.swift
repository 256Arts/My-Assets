//
//  MyAssetsView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-06.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI
import SwiftData
import Charts

struct MyAssetsView: View {
    
    @AppStorage(UserDefaults.Key.amountMarqueePeriod) var periodRawValue = "Month"
    @AppStorage(UserDefaults.Key.amountMarqueeShowAsCombinedValue) var showAsCombinedValue = false
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    @Query var unsortedNonStockAssets: [Asset]
    @Query var unsortedDebts: [Debt]

    @State var chartDataSource: FiveYearChart.ChartDataSource = .balance
    @State var showingSettings = false
    @State var showingNewAsset = false
    @State var showingNewDebt = false
    @State var period = Period(rawValue: UserDefaults.standard.string(forKey: UserDefaults.Key.amountMarqueePeriod) ?? "") ?? .month {
        didSet {
            periodRawValue = period.rawValue
        }
    }
    
    var nonStockAssets: [Asset] {
        unsortedNonStockAssets.sorted(by: { $0.currentValue > $1.currentValue })
    }
    var debts: [Debt] {
        unsortedDebts.sorted(by: { $0.currentValue > $1.currentValue })
    }
    var insights: InsightsGenerator {
        .init(data: data)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
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
                } header: {
                    Text("Balance")
                }
                Section {
                    ForEach(nonStockAssets) { asset in
                        NavigationLink(value: asset) {
                            AmountRow(symbol: asset.symbol ?? .defaultSymbol, label: asset.name ?? "", amount: asset.currentValue)
                        }
                    }
                    .onDelete(perform: deleteAsset)
                    Button {
                        self.showingNewAsset = true
                    } label: {
                        Label("New Asset", systemImage: "plus")
                    }
                } header: {
                    Text("Assets")
                }
                .symbolVariant(.fill)
                Section {
                    ForEach(debts) { debt in
                        NavigationLink(value: debt) {
                            AmountRow(symbol: debt.symbol ?? .defaultSymbol, label: debt.name ?? "", amount: debt.currentValue)
                        }
                    }
                    .onDelete(perform: deleteDebt)
                    Button {
                        self.showingNewDebt = true
                    } label: {
                        Label("New Debt", systemImage: "plus")
                    }
                } header: {
                    Text("Debts")
                }
                Section {
                    Picker("Chart Data", selection: $chartDataSource) {
                        ForEach(FiveYearChart.ChartDataSource.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    FiveYearChart(chartDataSource: $chartDataSource)
                        .padding(.top, 4)
                    
                    ForEach(Array(insights.generate().enumerated()), id: \.0) { (_, string) in
                        Text(string)
                    }
                } header: {
                    Text("Insights")
                }
                Section {
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
                    
                    if let netWorthPercentile = insights.netWorthPercentile() {
                        HStack {
                            Text("Net Worth:")
                                .bold()
                                .accessibilityHidden(true)
                            Spacer()
                            Gauge(value: netWorthPercentile) {
                                Text("Net Worth Percentile")
                            } currentValueLabel: {
                                Text(insights.netWorthPercentileString ?? "")
                            }
                            .gaugeStyle(.accessoryLinear)
                            .tint(LinearGradient(colors: [.red, .gray, .green], startPoint: .leading, endPoint: .trailing))
                            .accessibilityHidden(true)
                        }
                    }
                } header: {
                    Text("Net Worth")
                }
            }
            .navigationTitle("My Assets")
            .toolbar {
                #if !os(macOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                #endif
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            self.showingNewAsset = true
                        } label: {
                            Label("New Asset", systemImage: "plus.square")
                        }
                        Button {
                            self.showingNewDebt = true
                        } label: {
                            Label("New Debt", systemImage: "minus.square")
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .symbolVariant(.fill)
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            .navigationDestination(for: Asset.self) { asset in
                AssetView(asset: asset)
            }
            .navigationDestination(for: Debt.self) { debt in
                DebtView(debt: debt)
            }
        }
        .sheet(isPresented: self.$showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .sheet(isPresented: self.$showingNewAsset) {
            NavigationStack {
                NewAssetView()
            }
        }
        .sheet(isPresented: self.$showingNewDebt) {
            NavigationStack {
                NewDebtView()
            }
        }
    }
    
    func deleteAsset(at offsets: IndexSet) {
        for offset in offsets {
            let asset = self.data.assets[offset]
            if let index = self.data.nonStockAssets.firstIndex(of: asset) {
                modelContext.delete(asset)
                self.data.nonStockAssets.remove(at: index)
            } else if let index = self.data.stocks.firstIndex(where: { $0.symbol == asset.name }) {
                modelContext.delete(data.stocks[index])
                self.data.stocks.remove(at: index)
            }
        }
    }
    
    func deleteDebt(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(data.debts[offset])
            data.debts.remove(at: offset)
        }
    }
    
}

struct MyAssetsView_Previews: PreviewProvider {
    static var previews: some View {
        MyAssetsView()
    }
}
