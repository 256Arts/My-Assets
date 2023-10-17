//
//  MyAssetsView.swift
//  My Assets (watchOS) Watch App
//
//  Created by Jayden Irwin on 2023-07-28.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftUI
import SwiftData

struct MyAssetsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    
    @Query var unsortedNonStockAssets: [Asset]
    @Query var unsortedDebts: [Debt]
    
    var nonStockAssets: [Asset] {
        unsortedNonStockAssets.sorted(by: { $0.currentValue > $1.currentValue })
    }
    var debts: [Debt] {
        unsortedDebts.sorted(by: { $0.currentValue > $1.currentValue })
    }
    
    var body: some View {
        List {
            Section {
                ForEach(nonStockAssets) { asset in
                    AmountRow(symbol: asset.symbol ?? .defaultSymbol, label: asset.name!, amount: asset.currentValue)
                }
                .onDelete(perform: deleteAsset)
            } header: {
                Text("My Assets")
            }
            Section {
                ForEach(debts) { debt in
                    AmountRow(symbol: debt.symbol ?? .defaultSymbol, label: debt.name!, amount: debt.currentValue)
                }
                .onDelete(perform: deleteDebt)
            } header: {
                Text("My Debts")
            }
        }
        .navigationTitle("My Assets")
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
    MyAssetsView()
}
