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
        static let whatsNewVersion = "whatsNewVersion"
        static let userType = "userType"
        static let otherHouseholdNetWorth = "otherHouseholdNetWorth"
        static let birthday = "birthday"
        static let amountMarqueePeriod = "amountMarqueePeriod"
        static let amountMarqueeShowAsCombinedValue = "amountMarqueeShowAsCombinedValue"
    }
    
    func register() {
        register(defaults: [
            Key.whatsNewVersion: 0,
            Key.userType: UserType.individual.rawValue,
            Key.otherHouseholdNetWorth: 0.0,
            Key.amountMarqueePeriod: Period.month.rawValue,
            Key.amountMarqueeShowAsCombinedValue: false
        ])
    }
    
}
