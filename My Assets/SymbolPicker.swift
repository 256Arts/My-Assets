//
//  SymbolPicker.swift
//  My Assets
//
//  Created by Jayden Irwin on 2021-10-26.
//  Copyright © 2021 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct SymbolPicker: View {
    
    @Binding var selected: Symbol
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 42, maximum: 42))]) {
            ForEach(Symbol.allCases) { symbol in
                ZStack {
                    if symbol == selected {
                        Circle()
                            .fill(symbol.color.gradient)
                    } else {
                        Circle()
                            .fill(Color(UIColor.tertiarySystemGroupedBackground))
                    }
                    Image(systemName: symbol.rawValue)
                        .foregroundColor(symbol == selected ? Color.white : symbol.color)
                }
                .frame(height: 42)
                .onTapGesture {
                    selected = symbol
                }
            }
        }
        .symbolVariant(.fill)
        .imageScale(.large)
        .font(.system(size: 17, weight: .medium))
        .padding(.horizontal, -4)
        .padding(.vertical, 12)
    }
}

struct SymbolPicker_Previews: PreviewProvider {
    static var previews: some View {
        SymbolPicker(selected: .constant(Symbol.defaultSymbol))
    }
}
