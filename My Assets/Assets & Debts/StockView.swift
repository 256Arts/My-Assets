//
//  StockView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-09-23.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct StockView: View {
    
    @Binding var stock: Stock
    
    var body: some View {
        Form {
            TextField("Number Of Shares", value: $stock.numberOfShares, formatter: NumberFormatter())
        }
        .navigationTitle("Stock")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    StockView(stock: .constant(Stock(symbol: "AAPL", shares: 10)))
}
