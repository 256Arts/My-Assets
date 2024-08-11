//
//  NewCreditCardView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2024-08-10.
//  Copyright © 2024 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct NewCreditCardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable var creditCard: CreditCard = CreditCard()
    
    var body: some View {
        List {
            Section {
                TextField("Name", text: Binding(get: {
                    creditCard.name ?? ""
                }, set: { newValue in
                    creditCard.name = newValue
                }))
                ColorPickerLink(colorName: $creditCard.colorName)
                TextEditor(text: Binding(get: {
                    creditCard.notes ?? ""
                }, set: { newValue in
                    creditCard.notes = newValue
                }))
            }
            Section {
                OptionalCurrencyField("Monthly Spend", value: $creditCard.monthlySpend)
                OptionalCurrencyField("Card Fee (Yearly)", value: $creditCard.cardFee)
                LabeledContent("Points/$") {
                    TextField("", value: $creditCard.pointsPerDollar, format: .number)
                        .multilineTextAlignment(.trailing)
                        #if !os(macOS)
                        .keyboardType(.decimalPad)
                        #endif
                }
                LabeledContent("Point Value") {
                    TextField("", value: $creditCard.pointValue, format: .number)
                        .multilineTextAlignment(.trailing)
                        #if !os(macOS)
                        .keyboardType(.decimalPad)
                        #endif
                }
                Picker("Reward Type", selection: $creditCard.rewardType) {
                    Text("Cash")
                        .tag(CreditCard.RewardType.cash)
                    Text("Gift Cards")
                        .tag(CreditCard.RewardType.giftCard)
                }
                LabeledContent("Minimum Redemption (Points)") {
                    TextField("", value: $creditCard.minimumRedemption, format: .number)
                        .multilineTextAlignment(.trailing)
                        #if !os(macOS)
                        .keyboardType(.numberPad)
                        #endif
                }
                if creditCard.rewardType == .giftCard {
                    LabeledContent("Time Holding Gift Card (Months)") {
                        TextField("", value: $creditCard.timeHoldingGiftCard, format: .number)
                            .multilineTextAlignment(.trailing)
                            #if !os(macOS)
                            .keyboardType(.decimalPad)
                            #endif
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    self.dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    modelContext.insert(creditCard)
                    self.dismiss()
                }
                .disabled(creditCard.name?.isEmpty != false)
            }
        }
        .navigationTitle("New Credit Card")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NewCreditCardView(creditCard: CreditCard())
}
