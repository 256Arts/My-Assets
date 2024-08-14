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
//            OptionalTextField("Symbol", text: $stock.symbol)
//                #if !os(macOS)
//                .autocapitalization(.allCharacters)
//                #endif
//                .disableAutocorrection(true)
            TextField("Quantity", value: $stock.quantity, formatter: NumberFormatter())
        }
        .navigationTitle("Stock")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    StockView(stock: .constant(Stock(symbol: "AAPL", quantity: 10)))
}
