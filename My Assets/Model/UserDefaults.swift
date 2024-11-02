//
//  UserDefaults.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2021-10-21.
//  Copyright © 2021 256 Arts Developer. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    struct Key {
        static let userType = "userType"
        static let otherHouseholdNetWorth = "otherHouseholdNetWorth"
        static let birthday = "birthday"
        static let tabViewCustomization = "tabViewCustomization"
        static let amountMarqueePeriod = "amountMarqueePeriod"
        static let amountMarqueeShowAsCombinedValue = "amountMarqueeShowAsCombinedValue"
        static let summaryScreenShowBalance = "summaryScreenShowBalance"
        static let summaryScreenBalanceShowChart = "summaryScreenBalanceShowChart"
        static let summaryScreenShowNetWorth = "summaryScreenShowNetWorth"
        static let summaryScreenNetWorthShowChart = "summaryScreenNetWorthShowChart"
        static let summaryScreenNetWorthShowPercentile = "summaryScreenNetWorthShowPercentile"
        static let summaryScreenShowCashFlows = "summaryScreenShowCashFlows"
        static let summaryScreenShowInsights = "summaryScreenShowInsights"
    }
    
    func register() {
        register(defaults: [
            Key.userType: UserType.individual.rawValue,
            Key.otherHouseholdNetWorth: 0.0,
            Key.amountMarqueePeriod: Period.month.rawValue,
            Key.amountMarqueeShowAsCombinedValue: false,
            Key.summaryScreenShowBalance: true,
            Key.summaryScreenBalanceShowChart: true,
            Key.summaryScreenShowNetWorth: true,
            Key.summaryScreenNetWorthShowChart: true,
            Key.summaryScreenNetWorthShowPercentile: false,
            Key.summaryScreenShowCashFlows: true,
            Key.summaryScreenShowInsights: true
        ])
    }
    
}
