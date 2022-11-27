//
//  DecimalField.swift
//
//  Created by Edwin Watkeys on 9/20/19.
//  Copyright © 2019 Edwin Watkeys.
//

import SwiftUI
import Combine

struct DoubleField: View {
    
    let label: LocalizedStringKey
    @Binding var value: Double
    let formatter: NumberFormatter
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void
    
    // The text shown by the wrapped TextField. This is also the "source of
    // truth" for the `value`.
    @State private var textValue: String = ""
    
    // When the view loads, `textValue` is not synced with `value`.
    // This flag ensures we don't try to get a `value` out of `textValue`
    // before the view is fully initialized.
    @State private var hasInitialTextValue = false
    
    init(
        _ label: LocalizedStringKey,
        value: Binding<Double>,
        formatter: NumberFormatter,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = {}
    ) {
        self.label = label
        _value = value
        self.formatter = formatter
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    var body: some View {
        TextField(label, text: $textValue, onEditingChanged: { isInFocus in
            // When the field is in focus we replace the field's contents
            // with a plain unformatted number. When not in focus, the field
            // is treated as a label and shows the formatted value.
            if isInFocus {
                if formatter.numberStyle == .percent {
                    self.textValue = (value * 100).description
                } else {
                    self.textValue = self.value.description
                }
            } else {
                let f = self.formatter
                var newValue = f.number(from: self.textValue)?.doubleValue
                if newValue == nil {
                    newValue = Double(self.textValue)
                    if let temp = newValue, f.numberStyle == .percent {
                        newValue = temp / 100
                    }
                }
                self.textValue = f.string(for: newValue) ?? ""
            }
            self.onEditingChanged(isInFocus)
        }, onCommit: {
            self.onCommit()
        })
            .onChange(of: textValue) {
                guard self.hasInitialTextValue else {
                    // We don't have a usable `textValue` yet -- bail out.
                    return
                }
                // This is the only place we update `value`; `formatter.number(from:)` will not work with "$"
                if let val = self.formatter.number(from: $0)?.doubleValue {
                    self.value = val
                } else if formatter.numberStyle == .percent, let val = try? Double($0, format: .percent) {
                    self.value = val
                } else if let val = try? Double($0, format: .number) {
                    self.value = val
                }
            }
            .onAppear { // Otherwise textfield is empty when view appears
                self.hasInitialTextValue = true
                // Any `textValue` from this point on is considered valid and
                // should be synced with `value`.
                // Synchronize `textValue` with `value`; can't be done earlier
                self.textValue = self.formatter.string(from: NSDecimalNumber(value: value)) ?? ""
            }
            .keyboardType(.decimalPad)
    }
}

struct DoubleField_Previews: PreviewProvider {
    static var previews: some View {
        DoubleField("Title", value: .constant(0.0), formatter: NumberFormatter())
    }
}
