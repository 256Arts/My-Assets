//
//  CreditCardView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2024-07-21.
//  Copyright © 2024 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct CreditCardView: View {
    
    @EnvironmentObject var data: FinancialData
    
    var insights: InsightsGenerator {
        .init(data: data)
    }
    
    @Bindable var creditCard: CreditCard
    
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
                LabeledContent("Liquid Assets Interest", value: insights.avgAnnualBalanceInterestString)
            }
            
            if let rewardsRate = creditCard.rewardsRate(avgAnnualBalanceInterest: insights.avgAnnualBalanceInterest) {
                Section {
                    LabeledContent("Your Savings Rate", value: percentFormatter.string(from: NSNumber(value: rewardsRate))!)
                } footer: {
                    Text("Savings rate includes interest you earn on your liquid assets while your purchase payments are being defered (by 1-2 months) by the credit card.")
                }
            }
        }
        .navigationTitle("Credit Card")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CreditCardView(creditCard: CreditCard())
}
