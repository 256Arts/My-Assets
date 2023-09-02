//
//  UserDefaults.swift
//  My Assets
//
//  Created by Jayden Irwin on 2021-10-21.
//  Copyright © 2021 Jayden Irwin. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    struct Key {
        static let whatsNewVersion = "whatsNewVersion"
        static let financialData = "financialData" // iCloud
        static let userType = "userType"
        static let otherHouseholdNetWorth = "otherHouseholdNetWorth"
        static let birthday = "birthday"
        static let amountMarqueePeriod = "amountMarqueePeriod"
        static let amountMarqueeShowAsCombinedValue = "amountMarqueeShowAsCombinedValue"
        
        #if DEBUG
        static let showDebugData = "showDebugData"
        #endif
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
