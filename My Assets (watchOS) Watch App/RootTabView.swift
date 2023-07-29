//
//  RootTabView.swift
//  My Assets (watchOS) Watch App
//
//  Created by Jayden Irwin on 2023-07-28.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct RootTabView: View {
    
    @ObservedObject var cloudController: CloudController = .shared
    
    var body: some View {
        if let financialData = cloudController.financialData {
            TabView {
                MyAssetsView()
            }
            .environmentObject(financialData)
        } else if cloudController.decodeError != nil {
            VStack {
                Image(systemName: "exclamationmark.triangle")
                Text("Failed to load data.")
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
        }
    }
}

#Preview {
    RootTabView()
}
