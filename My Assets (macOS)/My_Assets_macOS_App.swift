//
//  My_Assets__macOS_App.swift
//  My Assets (macOS)
//
//  Created by Jayden Irwin on 2022-03-26.
//  Copyright © 2022 Jayden Irwin. All rights reserved.
//

import SwiftUI

let appWhatsNewVersion = 1

@main
struct My_Assets_macOS_App: App {
    
    init() {
        UserDefaults.standard.register()
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}
