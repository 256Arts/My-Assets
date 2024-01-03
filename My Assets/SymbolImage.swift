//
//  SymbolImage.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2021-11-23.
//  Copyright © 2021 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct SymbolImage: View {
    
    let symbol: Symbol
    
    var body: some View {
        Image(systemName: symbol.rawValue)
            .symbolVariant(.fill)
            .foregroundColor(symbol.color)
            .font(.system(size: 17, weight: .medium))
            .frame(width: 32)
    }
}

#Preview {
    SymbolImage(symbol: .defaultSymbol)
}
