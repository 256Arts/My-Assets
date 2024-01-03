//
//  UserType.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2022-04-09.
//  Copyright © 2022 256 Arts Developer. All rights reserved.
//

import Foundation

enum UserType: String, Identifiable, CaseIterable {
    case individual = "Individual"
    case household = "Household"
    
    var id: Self { self }
}
