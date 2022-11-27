//
//  StockView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-09-23.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct StockView: View {
    
    @Binding var stock: Stock
    
    var body: some View {
        Form {
            TextField("Number Of Shares", value: $stock.numberOfShares, formatter: NumberFormatter())
        }
        .navigationTitle("Stock")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StockView_Previews: PreviewProvider {
    static var previews: some View {
        StockView(stock: .constant(Stock(symbol: "AAPL", shares: 10)))
    }
}
