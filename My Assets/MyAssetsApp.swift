//
//  MyAssetsApp.swift
//  My Assets
//
//  Created by Jayden Irwin on 2022-03-28.
//  Copyright © 2022 Jayden Irwin. All rights reserved.
//

import SwiftUI

let appWhatsNewVersion = 1

@main
struct MyAssetsApp: App {
    
    init() {
        UserDefaults.standard.register()
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    return formatter
}()

let currencyDeltaFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.positivePrefix = "+"
    return formatter
}()

let percentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1
    return formatter
}()
