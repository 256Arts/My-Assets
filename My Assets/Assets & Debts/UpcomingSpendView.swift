//
//  UpcomingSpendView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2024-01-02.
//  Copyright © 2024 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct UpcomingSpendView: View {
    
    @Bindable var spend: UpcomingSpend
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    
    init(spend: UpcomingSpend) {
        self.spend = spend
        _nameCopy = State(initialValue: spend.name ?? "")
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $nameCopy)
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
        .navigationTitle("Upcoming Spend")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onDisappear {
            spend.name = nameCopy
        }
    }
}

#Preview {
    UpcomingSpendView(spend: UpcomingSpend())
}
