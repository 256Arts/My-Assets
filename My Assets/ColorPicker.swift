//
//  ColorPicker.swift
//  My Assets
//
//  Created by Jayden Irwin on 2024-08-10.
//  Copyright © 2024 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct ColorPicker: View {
    
    #if targetEnvironment(macCatalyst)
    let itemSize: CGFloat = 32
    #else
    let itemSize: CGFloat = 42
    #endif
    
    @Binding var selected: ColorName
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: itemSize, maximum: itemSize))]) {
            ForEach(ColorName.allCases) { colorName in
                Circle()
                    .fill(colorName.color)
                    .overlay {
                        if colorName == selected {
                            Circle()
                                .stroke(lineWidth: 2)
                                .padding(-4)
                        }
                    }
                    .frame(height: itemSize)
                    .onTapGesture {
                        selected = colorName
                    }
            }
        }
        .symbolVariant(.fill)
        .imageScale(.large)
        .padding(.horizontal, -4)
        .padding(.vertical, 12)
    }
}
