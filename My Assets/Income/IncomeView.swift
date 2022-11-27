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
    var spentIncome: Double {
        data.totalExpenses / data.totalLiquidIncome
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        PieChart(data: [
                            .init(value: workingIncome, color: .gray),
                            .init(value: passiveLiquidIncome, color: .green),
                            .init(value: passiveNonLiquidIncome, color: Color(red: 0, green: 0.5, blue: 0))
                        ])
                        VStack(alignment: .trailing) {
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                Text("Working: " + currencyFormatter.string(from: NSNumber(value: workingIncome))!)
                            }
                            .fixedSize()
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(.green)
                                Text("Passive: " + currencyFormatter.string(from: NSNumber(value: passiveLiquidIncome))!)
                            }
                            .fixedSize()
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(Color(red: 0, green: 0.5, blue: 0))
                                Text("Passive (Non-Liquid): " + currencyFormatter.string(from: NSNumber(value: passiveNonLiquidIncome))!)
                            }
                            .fixedSize()
                        }
                        .symbolVariant(.fill)
                        .imageScale(.small)
                        .padding(.vertical, 20)
                    }
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
                        HStack {
                            SymbolImage(symbol: income.symbol)
                            Text(income.name)
                            Spacer()
                            Text(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings))!)
                        }
                    }
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(currencyFormatter.string(from: NSNumber(value: data.totalLiquidIncome))!)
                    }
                        .font(Font.headline)
                }
                if data.income.contains(where: { $0.fromAsset && !$0.isLiquid }) {
                    Section {
                        ForEach(data.income.filter({ $0.fromAsset && !$0.isLiquid })) { income in
                            HStack {
                                SymbolImage(symbol: income.symbol)
                                Text(income.name)
                                Spacer()
                                Text(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings))!)
                            }
                        }
                        HStack {
                            Text("Total (With Non-Liquid)")
                            Spacer()
                            Text(currencyFormatter.string(from: NSNumber(value: data.totalIncome))!)
                        }
                        .font(Font.headline)
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
