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
    @EnvironmentObject var data: FinancialData
    
    var insights: InsightsGenerator {
        .init(data: data)
    }
    
    @Bindable var creditCard: CreditCard = CreditCard()
    
    private var deferedPaymentInterest: Double? {
        guard let monthlySpend = creditCard.monthlySpend else { return nil }
        
        let avgDeferedPaymentMonths = 1.5
        return (monthlySpend * (insights.avgAnnualBalanceInterest / 12) * avgDeferedPaymentMonths) * 12
    }
    
    private var interestLost: Double? {
        guard let monthlyRewardsEarned = creditCard.monthlyRewardsEarned, let minimumRedemption = creditCard.minimumRedemption, let rewardType = creditCard.rewardType, let timeHoldingGiftCard = creditCard.timeHoldingGiftCard else { return nil }
        
        let deferedRedemptionLoss: Double = {
            let redemptionsPerMonth = (monthlyRewardsEarned / 12) / Double(max(1, minimumRedemption))
            
            /* Guess: Redemptions will happen half as often as avg calculated.
             If user can redeem twice in a month, we assume they can always redeem 100% of their rewards. */
            let fractionOfRewardsRedeemed = min(redemptionsPerMonth / 2, 1)
            
            return fractionOfRewardsRedeemed * monthlyRewardsEarned * (insights.avgAnnualBalanceInterest / 12)
        }()
        
        let deferedGiftCardUseLoss = monthlyRewardsEarned * (insights.avgAnnualBalanceInterest / 12) * (rewardType == .giftCard ? timeHoldingGiftCard : 0)
        
        return deferedRedemptionLoss + deferedGiftCardUseLoss
    }
    
    private var rewardsRate: Double? {
        guard let deferedPaymentInterest, let monthlyRewardsEarned = creditCard.monthlyRewardsEarned, let cardFee = creditCard.cardFee, let interestLost, let monthlyRewardsLost = creditCard.monthlyRewardsLost, let monthlySpend = creditCard.monthlySpend else { return nil }
        
        return (deferedPaymentInterest + monthlyRewardsEarned - cardFee - interestLost - monthlyRewardsLost) / (monthlySpend * 12)
    }
    
    var body: some View {
        List {
            Section {
                TextField("Name", text: Binding(get: {
                    creditCard.name ?? ""
                }, set: { newValue in
                    creditCard.name = newValue
                }))
                ColorPickerLink(colorName: $creditCard.colorName)
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
            
            if let rewardsRate {
                Section {
                    LabeledContent("Your Savings Rate", value: percentFormatter.string(from: NSNumber(value: rewardsRate))!)
                } footer: {
                    Text("Savings rate includes interest you earn on your liquid assets while your purchase payments are being defered (by 1-2 months) by the credit card.")
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
                .disabled(creditCard.name?.isEmpty == false)
            }
        }
        .navigationTitle("New Credit Card")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NewCreditCardView(creditCard: CreditCard())
}
