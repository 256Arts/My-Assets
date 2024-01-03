//
//  AmountRow.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2023-07-28.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct AmountRow: View {
    
    let symbol: Symbol
    let label: String
    let amount: Double
    
    var body: some View {
        #if os(watchOS)
        HStack {
            SymbolImage(symbol: symbol)
            VStack(alignment: .leading) {
                Text(label)
                    .lineLimit(1)
                Text(currencyFormatter.string(from: NSNumber(value: amount))!)
                    .foregroundStyle(.secondary)
            }
        }
        #else
        LabeledContent {
            Text(currencyFormatter.string(from: NSNumber(value: amount))!)
        } label: {
            HStack {
                SymbolImage(symbol: symbol)
                Text(label)
            }
        }
        #endif
    }
}
