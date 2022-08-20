//
//  UserType.swift
//  My Assets
//
//  Created by Jayden Irwin on 2022-04-09.
//  Copyright © 2022 Jayden Irwin. All rights reserved.
//

import Foundation

enum UserType: String, Identifiable, CaseIterable {
    case individual = "Individual"
    case household = "Household"
    
    var id: Self { self }
}
