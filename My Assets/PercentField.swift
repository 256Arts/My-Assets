//
//  DecimalField.swift
//
//  Created by Edwin Watkeys on 9/20/19.
//  Copyright © 2019 Edwin Watkeys.
//

import SwiftUI
import Combine

struct PercentField: View {
    
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
            TextField(label, value: $updatedValue, format: .percent)
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
    PercentField("Title", value: .constant(0.0))
}

struct OptionalPercentField: View {
    
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
        PercentField(label, value: Binding(get: {
            value ?? 0
        }, set: { newValue in
            value = newValue
        }))
    }
}

#Preview {
    OptionalPercentField("Title", value: .constant(0.0))
}
