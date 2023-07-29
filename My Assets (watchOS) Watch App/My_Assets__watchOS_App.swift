//
//  My_Assets__watchOS_App.swift
//  My Assets (watchOS) Watch App
//
//  Created by Jayden Irwin on 2023-07-28.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftUI

@main
struct My_Assets__watchOS__Watch_AppApp: App {
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
