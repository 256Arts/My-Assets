//
//  NewStockView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-06.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct NewStockView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var data: FinancialData
    
    @State var stockSymbol = ""
    @State var quantity = 0.0
    
    var body: some View {
        Form {
            TextField("Symbol", text: $stockSymbol)
                #if !os(macOS)
                .autocapitalization(.allCharacters)
                #endif
                .disableAutocorrection(true)
            TextField("Quantity", value: $quantity, formatter: NumberFormatter())
        }
            .navigationTitle("New Stock")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        self.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "checkmark") {
                        Task {
                            let stock = Stock(symbol: self.stockSymbol, quantity: self.quantity)
                            try? await stock.fetchPrices()
                            modelContext.insert(stock)
                            self.data.stocks.append(stock)
                        }
                        self.dismiss()
                    }
                }
            }
    }
}

#Preview {
    NewStockView()
}
