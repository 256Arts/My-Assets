//
//  IncomeView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-07.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI
import SwiftData
import Charts

struct IncomeView: View {
    
    struct SectorData: Plottable, Identifiable {
        
        enum Effort: Identifiable {
            case working, passive, passiveNonLiquid
            
            var id: Self { self }
            var title: String {
                switch self {
                case .working:
                    "Working"
                case .passive:
                    "Passive"
                case .passiveNonLiquid:
                    "Passive (Non-Liquid)"
                }
            }
            var icon: Image {
                switch self {
                case .working:
                    Image(systemName: "building")
                case .passive:
                    Image(systemName: "arrow.triangle.2.circlepath")
                case .passiveNonLiquid:
                    Image(systemName: "house")
                }
            }
            var color: Color {
                switch self {
                case .working:
                    .gray
                case .passive:
                    .green
                case .passiveNonLiquid:
                    Color(red: 0, green: 0.5, blue: 0)
                }
            }
        }
        
        let effort: Effort
        var id: Effort { effort }
        let income: Double
        var primitivePlottable: Double { income }
        
        init(effort: Effort, income: Double) {
            self.effort = effort
            self.income = income
        }
        
        init?(primitivePlottable: Double) { nil }
    }
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    
    @Query(sort: [SortDescriptor(\Income.monthlyEarnings, order: .reverse)]) var nonAssetIncome: [Income]
    
    @State var selectedIncome: Double?
    @State var selectedSector: SectorData?
    @State var showingDetail = false

    var workingIncome: Double {
        data.income.filter({ !$0.isPassive! }).reduce(0, { $0 + $1.monthlyEarnings! })
    }
    var passiveLiquidIncome: Double {
        data.income.filter({ $0.isPassive! && $0.isLiquid! }).reduce(0, { $0 + $1.monthlyEarnings! })
    }
    var passiveNonLiquidIncome: Double {
        data.income.filter({ $0.isPassive! && !$0.isLiquid! }).reduce(0, { $0 + $1.monthlyEarnings! })
    }
    var pieChartData: [SectorData] {
        [
            .init(effort: .working, income: workingIncome),
            .init(effort: .passive, income: passiveLiquidIncome),
            .init(effort: .passiveNonLiquid, income: passiveNonLiquidIncome)
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
                        SectorMark(angle: .value("Value", sector.income), innerRadius: .ratio(0.5), angularInset: 1)
                            .foregroundStyle(by: .value("Effort", sector.effort.title))
                            .cornerRadius(4)
                            .annotation(position: .overlay) {
                                sector.effort.icon
                                    .symbolVariant(.fill)
                                    .shadow(radius: 8)
                                    .opacity(selectedSector == nil || selectedSector?.id == sector.id ? 1.0 : 0.5)
                            }
                            .opacity(selectedSector == nil || selectedSector?.id == sector.id ? 1.0 : 0.5)
                    }
                    .chartLegend(position: .trailing)
                    .chartForegroundStyleScale(range: pieChartData.map({ $0.effort.color }))
                    .chartAngleSelection(value: $selectedIncome)
                    .frame(height: 110)
                    .overlay(alignment: .topLeading) {
                        if selectedSector != nil {
                            Button("Reset") {
                                selectedSector = nil
                            }
                        }
                    }
                }
                Section {
                    ForEach(nonAssetIncome) { income in
                        NavigationLink(value: income) {
                            AmountRow(symbol: income.symbol ?? .defaultSymbol, label: income.name ?? "", amount: income.monthlyEarnings!)
                                .opacity((selectedSector?.effort ?? .working) == .working ? 1 : 0.5)
                                .accessibilityElement()
                                .accessibilityLabel(income.name ?? "")
                                .accessibilityValue(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings!))!)
                        }
                    }
                    .onDelete(perform: delete)
                    ForEach(data.income.filter({ $0.fromAsset! && $0.isLiquid! })) { income in
                        AmountRow(symbol: income.symbol ?? .defaultSymbol, label: income.name ?? "", amount: income.monthlyEarnings!)
                            .opacity((selectedSector?.effort ?? .passive) == .passive ? 1 : 0.5)
                            .accessibilityElement()
                            .accessibilityLabel(income.name ?? "")
                            .accessibilityValue(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings!))!)
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
                if data.income.contains(where: { $0.fromAsset! && !$0.isLiquid! }) {
                    Section {
                        ForEach(data.income.filter({ $0.fromAsset! && !$0.isLiquid! })) { income in
                            AmountRow(symbol: income.symbol ?? .defaultSymbol, label: income.name ?? "", amount: income.monthlyEarnings!)
                                .opacity((selectedSector?.effort ?? .passiveNonLiquid) == .passiveNonLiquid ? 1 : 0.5)
                                .accessibilityElement()
                                .accessibilityLabel(income.name ?? "")
                                .accessibilityValue(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings!))!)
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
                    Button {
                        self.showingDetail.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .symbolVariant(.fill)
                    }
                }
            }
            .navigationDestination(for: Income.self) { income in
                IncomeSourceView(income: income)
            }
        }
        .sheet(isPresented: self.$showingDetail) {
            NavigationStack {
                NewIncomeSourceView()
            }
        }
        .onChange(of: selectedIncome) { (_, newValue: Double?) in
            if let newValue {
                selectedSector = findSelectedSector(value: newValue)
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(data.nonAssetIncome[offset])
        }
        self.data.nonAssetIncome.remove(atOffsets: offsets)
    }
    
    private func findSelectedSector(value: Double) -> SectorData? {
        var totalIncome = 0.0
     
        return pieChartData.first { sector in
            totalIncome += sector.income
            return value <= totalIncome
        }
    }
    
}

struct IncomeView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeView()
    }
}
