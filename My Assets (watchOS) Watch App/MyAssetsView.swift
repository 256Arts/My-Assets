//
//  MyAssetsView.swift
//  My Assets (watchOS) Watch App
//
//  Created by Jayden Irwin on 2023-07-28.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct MyAssetsView: View {
    
    @EnvironmentObject var data: FinancialData
    
    var body: some View {
        List {
            Section {
                ForEach($data.nonStockAssets) { $asset in
                    AmountRow(symbol: asset.symbol ?? .defaultSymbol, label: asset.name!, amount: asset.currentValue)
                }
                .onDelete(perform: deleteAsset)
            } header: {
                Text("My Assets")
            }
            Section {
                ForEach($data.debts) { $debt in
                    AmountRow(symbol: debt.symbol ?? .defaultSymbol, label: debt.name!, amount: debt.currentValue)
                }
                .onDelete(perform: deleteDebt)
            } header: {
                Text("My Debts")
            }
        }
        .presentationBackground(.blue)
    }
    
    func deleteAsset(at offsets: IndexSet) {
        for offset in offsets {
            let asset = self.data.assets[offset]
            if let index = self.data.nonStockAssets.firstIndex(of: asset) {
                self.data.nonStockAssets.remove(at: index)
            } else if let index = self.data.stocks.firstIndex(where: { $0.symbol == asset.name }) {
                self.data.stocks.remove(at: index)
            }
        }
    }
    
    func deleteDebt(at offsets: IndexSet) {
        for offset in offsets {
            data.debts.remove(at: offset)
        }
    }
}

#Preview {
    MyAssetsView()
}
