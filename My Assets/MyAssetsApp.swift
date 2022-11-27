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
