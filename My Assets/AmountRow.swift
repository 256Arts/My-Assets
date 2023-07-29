//
//  AmountRow.swift
//  My Assets
//
//  Created by Jayden Irwin on 2023-07-28.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct AmountRow: View {
    
    let symbol: Symbol
    let label: String
    let amount: Double
    
    var body: some View {
        LabeledContent {
            Text(currencyFormatter.string(from: NSNumber(value: amount))!)
        } label: {
            HStack {
                SymbolImage(symbol: symbol)
                Text(label)
            }
        }
    }
}