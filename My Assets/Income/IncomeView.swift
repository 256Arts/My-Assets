//
//  IncomeView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI
import Charts

struct IncomeView: View {
    
    struct SectorData: Identifiable {
        let effort: String
        var id: String { effort }
        let color: Color
        let income: Double
    }
    
    @EnvironmentObject var data: FinancialData
    @State var showingDetail = false

    var workingIncome: Double {
        data.income.filter({ !$0.isPassive }).reduce(0, { $0 + $1.monthlyEarnings })
    }
    var passiveLiquidIncome: Double {
        data.income.filter({ $0.isPassive && $0.isLiquid }).reduce(0, { $0 + $1.monthlyEarnings })
    }
    var passiveNonLiquidIncome: Double {
        data.income.filter({ $0.isPassive && !$0.isLiquid }).reduce(0, { $0 + $1.monthlyEarnings })
    }
    var pieChartData: [SectorData] {
        [
            .init(effort: "Working", color: .gray, income: workingIncome),
            .init(effort: "Passive", color: .green, income: passiveLiquidIncome),
            .init(effort: "Passive (Non-Liquid)", color: Color(red: 0, green: 0.5, blue: 0), income: passiveNonLiquidIncome)
        ]
    }
    var spentIncome: Double {
        data.totalExpenses / data.totalLiquidIncome
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Chart(pieChartData) { sector in
                        SectorMark(angle: .value("Value", sector.income))
                            .foregroundStyle(by: .value("Effort", sector.effort))
                    }
                    .chartLegend(position: .trailing)
                    .chartForegroundStyleScale(range: pieChartData.map({ $0.color }))
                    .frame(height: 100)
                }
                Section {
                    ForEach($data.nonAssetIncome) { $income in
                        NavigationLink(destination: IncomeSourceView(income: $income)) {
                            HStack {
                                SymbolImage(symbol: income.symbol)
                                Text(income.name)
                                Spacer()
                                Text(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings))!)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                    ForEach(data.income.filter({ $0.fromAsset && $0.isLiquid })) { income in
                        AmountRow(symbol: income.symbol, label: income.name, amount: income.monthlyEarnings)
                            .accessibilityElement()
                            .accessibilityLabel(income.name)
                            .accessibilityValue(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings))!)
                    }
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(currencyFormatter.string(from: NSNumber(value: data.totalLiquidIncome))!)
                    }
                        .font(Font.headline)
                        .accessibilityElement()
                        .accessibilityLabel("Total")
                        .accessibilityValue(currencyFormatter.string(from: NSNumber(value: data.totalLiquidIncome))!)
                }
                if data.income.contains(where: { $0.fromAsset && !$0.isLiquid }) {
                    Section {
                        ForEach(data.income.filter({ $0.fromAsset && !$0.isLiquid })) { income in
                            AmountRow(symbol: income.symbol, label: income.name, amount: income.monthlyEarnings)
                                .accessibilityElement()
                                .accessibilityLabel(income.name)
                                .accessibilityValue(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings))!)
                        }
                        HStack {
                            Text("Total (With Non-Liquid)")
                            Spacer()
                            Text(currencyFormatter.string(from: NSNumber(value: data.totalIncome))!)
                        }
                        .font(Font.headline)
                        .accessibilityElement()
                        .accessibilityLabel("Total (With Non-Liquid)")
                        .accessibilityValue(currencyFormatter.string(from: NSNumber(value: data.totalIncome))!)
                    }
                }
                if spentIncome.isFinite {
                    Section {
                        Gauge(value: spentIncome) {
                            Text("Spent Income")
                        } currentValueLabel: {
                            Text("Spent Income: \(percentFormatter.string(from: NSNumber(value: spentIncome))!)")
                        }
                        .gaugeStyle(.accessoryLinear)
                        .tint(LinearGradient(colors: [.green, .gray, .red], startPoint: .leading, endPoint: .trailing))
                    }
                }
            }
            .navigationTitle("Income")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        self.showingDetail.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                            .symbolVariant(.fill)
                    }
                }
            }
        }
        .sheet(isPresented: self.$showingDetail) {
            NavigationStack {
                NewIncomeSourceView()
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.data.nonAssetIncome.remove(atOffsets: offsets)
    }
    
}

struct IncomeView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeView()
    }
}
