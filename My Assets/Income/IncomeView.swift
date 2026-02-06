//
//  IncomeView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-07.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
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
    @Environment(FinancialData.self) private var data
    
    @Query(sort: [SortDescriptor(\Income.amount, order: .reverse)]) var incomes: [Income]
    
    @State var selectedIncome: Double?
    @State var selectedSector: SectorData?
    @State var showingDetail = false
    @State var showingDeleteError = false

    var workingIncome: Double {
        incomes.filter({ $0.isPassive != true }).reduce(0, { $0 + ($1.monthlyEarnings ?? 0) })
    }
    var passiveLiquidIncome: Double {
        incomes.filter({ $0.isPassive == true && $0.isLiquid == true }).reduce(0, { $0 + ($1.monthlyEarnings ?? 0) })
    }
    var passiveNonLiquidIncome: Double {
        incomes.filter({ $0.isPassive == true && $0.isLiquid != true }).reduce(0, { $0 + ($1.monthlyEarnings ?? 0) })
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
                    HStack {
                        Chart(pieChartData) { sector in
                            SectorMark(angle: .value("Value", sector.income), innerRadius: .ratio(0.5), angularInset: 1)
                                .foregroundStyle(by: .value("Effort", sector.effort.title))
                                .cornerRadius(4)
                            //                            .annotation(position: .overlay) {
                            //                                sector.effort.icon
                            //                                    .symbolVariant(.fill)
                            //                                    .foregroundStyle(Color.white)
                            //                                    .shadow(radius: 8)
                            //                                    .opacity(selectedSector == nil || selectedSector?.id == sector.id ? 1.0 : 0.5)
                            //                            }
                                .opacity(selectedSector == nil || selectedSector?.id == sector.id ? 1.0 : 0.5)
                        }
                        .chartLegend(position: .trailing)
                        .chartForegroundStyleScale(range: pieChartData.map({ $0.effort.color }))
                        .chartAngleSelection(value: $selectedIncome)
                        .overlay(alignment: .topTrailing) {
                            if selectedSector != nil {
                                Button("Reset") {
                                    selectedSector = nil
                                }
                            }
                        }
                        .padding(6)
                        .frame(idealHeight: .infinity, maxHeight: .infinity)
                        .background(rowBackgroundColor, in: RoundedRectangle(cornerRadius: 12))
                        
                        if spentIncome.isFinite, 0 < spentIncome {
                            VStack(spacing: 0) {
                                Gauge(value: spentIncome) {
                                    EmptyView()
                                } currentValueLabel: {
                                    Text(shortPercentFormatter.string(from: NSNumber(value: spentIncome))!)
                                }
                                .gaugeStyle(.accessoryCircular)
                                .tint(LinearGradient(colors: [.green, .gray, .red], startPoint: .leading, endPoint: .trailing))
                                
                                Text("Spent Income")
                                    .multilineTextAlignment(.center)
                                    .font(.caption)
                            }
                            .padding(6)
                            .frame(idealHeight: .infinity, maxHeight: .infinity)
                            .background(rowBackgroundColor, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .frame(height: 130)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden) // For macOS
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                Section {
                    ForEach(incomes.filter({ $0.isLiquid! })) { income in
                        NavigationLink(value: income) {
                            AmountRow(symbol: income.symbol ?? .defaultSymbol, label: income.name ?? "", amount: income.monthlyEarnings ?? 0)
                                .opacity((selectedSector?.effort ?? .working) == .working ? 1 : 0.5)
                                .accessibilityElement()
                                .accessibilityLabel(income.name ?? "")
                                .accessibilityValue(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings ?? 0))!)
                        }
                    }
                    .onDelete(perform: delete)
                    
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
                
                if incomes.contains(where: { !$0.isLiquid! }) {
                    Section {
                        ForEach(incomes.filter({ !$0.isLiquid! })) { income in
                            AmountRow(symbol: income.symbol ?? .defaultSymbol, label: income.name ?? "", amount: income.monthlyEarnings ?? 0)
                                .opacity((selectedSector?.effort ?? .passiveNonLiquid) == .passiveNonLiquid ? 1 : 0.5)
                                .accessibilityElement()
                                .accessibilityLabel(income.name ?? "")
                                .accessibilityValue(currencyFormatter.string(from: NSNumber(value: income.monthlyEarnings ?? 0))!)
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
            }
            .navigationTitle("Income")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") {
                        self.showingDetail.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .tint(.green)
                }
            }
            .navigationDestination(for: Income.self) { income in
                IncomeSourceView(income: income)
            }
        }
        .alert("Unable to Delete", isPresented: $showingDeleteError, actions: {
            Button("OK") { }
        })
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
    
    private var rowBackgroundColor: Color {
        #if canImport(UIKit)
        Color(UIColor.secondarySystemGroupedBackground)
        #else
        Color(NSColor.secondarySystemFill)
        #endif
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            let income = incomes[offset]
            guard income.fromAsset == nil else {
                showingDeleteError = true
                return
            }
            
            modelContext.delete(income)
            data.income = incomes
        }
    }
    
    private func findSelectedSector(value: Double) -> SectorData? {
        var totalIncome = 0.0
     
        return pieChartData.first { sector in
            totalIncome += sector.income
            return value <= totalIncome
        }
    }
    
}

#Preview {
    IncomeView()
}
