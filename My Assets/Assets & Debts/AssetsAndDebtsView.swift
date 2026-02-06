//
//  AssetsAndDebtsView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-06.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI
import SwiftData
import Charts

struct AssetsAndDebtsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(FinancialData.self) private var data
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    @Query var unsortedNonStockAssets: [Asset]
    @Query var unsortedDebts: [Debt]

    @State var showingNewAsset = false
    @State var showingNewDebt = false
    
    var nonStockAssets: [Asset] {
        unsortedNonStockAssets.sorted(by: { $0.currentValue > $1.currentValue })
    }
    var debts: [Debt] {
        unsortedDebts.sorted(by: { $0.currentValue > $1.currentValue })
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Assets") {
                    ForEach(nonStockAssets) { asset in
                        NavigationLink(value: asset) {
                            AmountRow(symbol: asset.symbol ?? .defaultSymbol, label: asset.name ?? "", amount: asset.currentValue)
                        }
                    }
                    .onDelete(perform: deleteAsset)
                    
                    Button("New Asset", systemImage: "plus") {
                        self.showingNewAsset = true
                    }
                }
                .symbolVariant(.fill)
                
                Section("Debts") {
                    ForEach(debts) { debt in
                        NavigationLink(value: debt) {
                            AmountRow(symbol: debt.symbol ?? .defaultSymbol, label: debt.name ?? "", amount: debt.currentValue)
                        }
                    }
                    .onDelete(perform: deleteDebt)
                    
                    Button("New Debt", systemImage: "plus") {
                        self.showingNewDebt = true
                    }
                }
            }
            .headerProminence(.increased)
            .navigationTitle("Assets & Debts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Add", systemImage: "plus") {
                        Button("New Asset", systemImage: "plus.square") {
                            self.showingNewAsset = true
                        }
                        
                        Button("New Debt", systemImage: "minus.square") {
                            self.showingNewDebt = true
                        }
                    }
                    .menuStyle(.button)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .tint(.blue)
                }
            }
            .navigationDestination(for: Asset.self) { asset in
                AssetView(asset: asset)
            }
            .navigationDestination(for: Debt.self) { debt in
                DebtView(debt: debt)
            }
            .navigationDestination(for: UpcomingSpend.self) { spend in
                UpcomingSpendView(spend: spend)
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

#Preview {
    AssetsAndDebtsView()
}
