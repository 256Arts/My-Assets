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
    
    // MARK: Relationships
    
    /// Purchases earning their own rate. `monthlySpend` and `pointsPerDollar` cover everything else.
    @Relationship(deleteRule: .cascade, inverse: \SpendingCategory.creditCard)
    var spendingCategories: [SpendingCategory]?
    
    // MARK: Computed Properties
    
    /// SwiftData relationships are unordered, so sort for a stable display order.
    var sortedSpendingCategories: [SpendingCategory] {
        (spendingCategories ?? []).sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    var totalMonthlySpend: Double {
        (spendingCategories ?? []).reduce(monthlySpend ?? 0) { $0 + ($1.monthlySpend ?? 0) }
    }
    var monthlyPoints: Double {
        (spendingCategories ?? []).reduce((monthlySpend ?? 0) * (pointsPerDollar ?? 0)) { $0 + $1.monthlyPoints }
    }
    /// Points per dollar, weighted by spend across every category.
    var blendedPointsPerDollar: Double? {
        totalMonthlySpend > 0 ? monthlyPoints / totalMonthlySpend : nil
    }
    var monthlyRewardsEarned: Double? {
        guard let pointValue, totalMonthlySpend > 0 else { return nil }
        
        return monthlyPoints * pointValue * 12
    }
    var monthlyRewardsLost: Double? {
        guard let monthlyRewardsEarned, let blendedPointsPerDollar, let pointValue else { return nil }
        
        return monthlyRewardsEarned * (blendedPointsPerDollar * pointValue)
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
        guard let monthlyRewardsEarned, let cardFee, let monthlyRewardsLost, let rewardType, let minimumRedemption, let timeHoldingGiftCard else { return nil }
        
        let monthlySpend = totalMonthlySpend
        
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

/// A type of purchase (e.g. dining) that earns its own points rate on a credit card.
@Model
final class SpendingCategory {
    
    var name: String?
    var monthlySpend: Double?
    var pointsPerDollar: Double?
    
    var creditCard: CreditCard?
    
    var monthlyPoints: Double {
        (monthlySpend ?? 0) * (pointsPerDollar ?? 0)
    }
    
    init(name: String = "", monthlySpend: Double = 0, pointsPerDollar: Double = 1.0) {
        self.name = name
        self.monthlySpend = monthlySpend
        self.pointsPerDollar = pointsPerDollar
    }
    
}
