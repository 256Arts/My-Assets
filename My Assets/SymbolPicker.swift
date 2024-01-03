//
//  SymbolPicker.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2021-10-26.
//  Copyright © 2021 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct SymbolPicker: View {
    
    #if targetEnvironment(macCatalyst)
    let itemSize: CGFloat = 32
    let symbolFontSize: CGFloat = 13
    #else
    let itemSize: CGFloat = 42
    let symbolFontSize: CGFloat = 17
    #endif
    
    @Binding var selected: Symbol
    
    var unselectedColor: Color {
        #if canImport(UIKit)
        Color(UIColor.tertiarySystemGroupedBackground)
        #else
        Color(NSColor.tertiarySystemFill)
        #endif
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: itemSize, maximum: itemSize))]) {
            ForEach(Symbol.allCases) { symbol in
                ZStack {
                    if symbol == selected {
                        Circle()
                            .fill(symbol.color.gradient)
                    } else {
                        Circle()
                            .fill(unselectedColor)
                    }
                    Image(systemName: symbol.rawValue)
                        .foregroundColor(symbol == selected ? Color.white : symbol.color)
                }
                .frame(height: itemSize)
                .onTapGesture {
                    selected = symbol
                }
            }
        }
        .symbolVariant(.fill)
        .imageScale(.large)
        .font(.system(size: symbolFontSize, weight: .medium))
        .padding(.horizontal, -4)
        .padding(.vertical, 12)
    }
}

#Preview {
    SymbolPicker(selected: .constant(Symbol.defaultSymbol))
}
