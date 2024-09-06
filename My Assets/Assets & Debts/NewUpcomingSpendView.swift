//
//  NewUpcomingSpendView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2024-01-02.
//  Copyright © 2024 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct NewUpcomingSpendView: View {
    
    var parentAsset: Asset?
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.modelContext) private var modelContext
    
    @State var spend = UpcomingSpend()
    
    var body: some View {
        Form {
            TextField("Name", text: Binding(get: {
                spend.name ?? ""
            }, set: { newValue in
                spend.name = newValue
            }))
                #if !os(macOS)
                .textInputAutocapitalization(.words)
                #endif
            OptionalCurrencyField("Cost", value: $spend.cost)
            DatePicker("Date", selection: Binding(get: {
                spend.date ?? .now
            }, set: { newValue in
                spend.date = newValue
            }), displayedComponents: .date)
            if let monthlyCost = spend.monthlyCost {
                Text("Save \(currencyFormatter.string(from: NSNumber(value: monthlyCost)) ?? "") monthly")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("New Upcoming Spend")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
//                    if let value = self.value {
//                        let interest = self.interest ?? 0.0
//                        self.debt.annualInterestFraction = interest
//                        self.debt.currentValue = value
                        modelContext.insert(spend)
                        if let parentAsset {
                            spend.asset = parentAsset
                        }
                        self.dismiss()
//                    }
                }
                .disabled(spend.cost == nil)
            }
        }
    }
}

#Preview {
    NewUpcomingSpendView()
}
