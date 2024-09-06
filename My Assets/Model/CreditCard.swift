//
//  CreditCard.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2024-08-10.
//  Copyright © 2024 256 Arts Developer. All rights reserved.
//

import SwiftData
import SwiftUI

@Model
final class CreditCard {
    
    enum RewardType: String, Codable, Identifiable {
        case cash, giftCard
        
        var id: Self { self }
    }
    
    var name: String?
    var colorName: ColorName?
    var notes: String?
    var cardFee: Double?
    var pointsPerDollar: Double?
    var pointValue: Double?
    var rewardType: RewardType?
    var minimumRedemption: Int?
    
    /// How long the gift card is held before it is used. (In months)
    var timeHoldingGiftCard: Double?
    var monthlySpend: Double?
    
    // MARK: Computed Properties
    
    var monthlyRewardsEarned: Double? {
        guard let pointsPerDollar, let pointValue, let monthlySpend else { return nil }
        
        return (pointsPerDollar * pointValue) * (monthlySpend * 12)
    }
    var monthlyRewardsLost: Double? {
        guard let monthlyRewardsEarned, let pointsPerDollar, let pointValue else { return nil }
        
        return monthlyRewardsEarned * (pointsPerDollar * pointValue)
    }
    
    // MARK: Init
    
    init(name: String = "", colorName: ColorName = .gray, cardFee: Double = 0.00, pointsPerDollar: Double = 1.0, pointValue: Double = 0.01, monthlySpend: Double = 2000.00) {
        self.name = name
        self.colorName = colorName
        self.cardFee = cardFee
        self.pointsPerDollar = pointsPerDollar
        self.pointValue = pointValue
        self.rewardType = .cash
        self.minimumRedemption = 1
        self.timeHoldingGiftCard = 2.0
        self.monthlySpend = monthlySpend
    }
    
    func rewardsRate(avgAnnualBalanceInterest: Double) -> Double? {
        guard let monthlyRewardsEarned, let cardFee, let monthlyRewardsLost, let rewardType, let minimumRedemption, let timeHoldingGiftCard, let monthlySpend else { return nil }
        
        let deferedPaymentInterest: Double = {
            let avgDeferedPaymentMonths = 1.5
            return (monthlySpend * (avgAnnualBalanceInterest / 12) * avgDeferedPaymentMonths) * 12
        }()
        
        let interestLost: Double = {
            let deferedRedemptionLoss: Double = {
                let redemptionsPerMonth = (monthlyRewardsEarned / 12) / Double(max(1, minimumRedemption))
                
                /* Guess: Redemptions will happen half as often as avg calculated.
                 If user can redeem twice in a month, we assume they can always redeem 100% of their rewards. */
                let fractionOfRewardsRedeemed = min(redemptionsPerMonth / 2, 1)
                
                return fractionOfRewardsRedeemed * monthlyRewardsEarned * (avgAnnualBalanceInterest / 12)
            }()
            
            let deferedGiftCardUseLoss = monthlyRewardsEarned * (avgAnnualBalanceInterest / 12) * (rewardType == .giftCard ? timeHoldingGiftCard : 0)
            
            return deferedRedemptionLoss + deferedGiftCardUseLoss
        }()
        
        return (deferedPaymentInterest + monthlyRewardsEarned - cardFee - interestLost - monthlyRewardsLost) / (monthlySpend * 12)
    }
    
}
