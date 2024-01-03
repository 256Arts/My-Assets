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
    @State var stockShares = 0.0
    
    var body: some View {
        Form {
            TextField("Symbol", text: $stockSymbol)
                #if !os(macOS)
                .autocapitalization(.allCharacters)
                #endif
                .disableAutocorrection(true)
//            DoubleField("Number Of Shares", value: $stockShares, formatter: NumberFormatter())
        }
            .navigationTitle("New Stock")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        self.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let stock = Stock(symbol: self.stockSymbol, shares: self.stockShares)
                        stock.fetchPrices()
                        modelContext.insert(stock)
                        self.data.stocks.append(stock)
                        self.dismiss()
                    } label: {
                        Text("Add")
                    }
                }
            }
    }
}

#Preview {
    NewStockView()
}
