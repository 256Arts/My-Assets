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
    @EnvironmentObject var data: FinancialData
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
            }
            .headerProminence(.increased)
            .navigationTitle("Assets & Debts")
            .toolbar {
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
