//
//  CurrencyField.swift
//  My Assets
//
//  Created by Jayden Irwin on 2023-11-07.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftUI
import Combine

struct CurrencyField: View {
    
    let label: LocalizedStringKey
    @Binding var value: Double
    
    @State private var updatedValue: Double
    @FocusState private var isFocused: Bool
    
    init(
        _ label: LocalizedStringKey,
        value: Binding<Double>
    ) {
        self.label = label
        _value = value
        _updatedValue = State(initialValue: value.wrappedValue)
    }
    
    var body: some View {
        LabeledContent(label) {
            TextField(label, value: $updatedValue, format: .currency(code: Locale.autoupdatingCurrent.currency?.identifier ?? "USD"))
                .focused($isFocused)
                .multilineTextAlignment(.trailing)
                .onChange(of: isFocused) { _, newValue in
                    if !newValue {
                        value = updatedValue
                    }
                }
                #if !os(macOS)
                .keyboardType(.decimalPad)
                #endif
        }
    }
}

#Preview {
    CurrencyField("Title", value: .constant(0.0))
}

struct OptionalCurrencyField: View {
    
    let label: LocalizedStringKey
    @Binding var value: Double?

    init(
        _ label: LocalizedStringKey,
        value: Binding<Double?>
    ) {
        self.label = label
        _value = value
    }

    var body: some View {
        CurrencyField(label, value: Binding(get: {
            value ?? 0
        }, set: { newValue in
            value = newValue
        }))
    }
}

#Preview {
    OptionalCurrencyField("Title", value: .constant(0.0))
}
