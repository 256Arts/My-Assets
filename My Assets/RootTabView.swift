//
//  ContentView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-06.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import WelcomeKit
import SwiftUI

struct RootTabView: View {
    
    enum Tab {
        case myAssets, income, expenses
    }
    
    let welcomeFeatures = [
        WelcomeFeature(image: Image(systemName: "banknote"), title: "Your Assets", body: "Track investments you own."),
        WelcomeFeature(image: Image(systemName: "tray.and.arrow.down"), title: "Income", body: "Track monthly income items."),
        WelcomeFeature(image: Image(systemName: "tray.and.arrow.up"), title: "Expenses", body: "Track monthly expense items.")
    ]
    
    @AppStorage(UserDefaults.Key.whatsNewVersion) var whatsNewVersion = 0

    @ObservedObject var cloudController: CloudController = .shared
    
    @State var selectedTab: Tab = .myAssets
    @State var showingWelcome = false
    
    var body: some View {
        if let financialData = cloudController.financialData {
            TabView(selection: $selectedTab) {
                MyAssetsView()
                    .tabItem {
                        Label("My Assets", systemImage: "banknote")
                    }
                    .tag(Tab.myAssets)
                IncomeView()
                    .tabItem {
                        Label("Income", systemImage: "tray.and.arrow.down")
                    }
                    .tag(Tab.income)
                ExpensesView()
                    .tabItem {
                        Label("Expenses", systemImage: "tray.and.arrow.up")
                    }
                    .tag(Tab.expenses)
            }
            .accentColor({
                switch selectedTab {
                case .myAssets:
                    return nil
                case .income:
                    return .green
                case .expenses:
                    return .red
                }
            }())
            .onAppear {
                if whatsNewVersion < appWhatsNewVersion {
                    showingWelcome = true
                }
            }
            .sheet(isPresented: $showingWelcome, onDismiss: {
                if whatsNewVersion < appWhatsNewVersion {
                    whatsNewVersion = appWhatsNewVersion
                }
            }, content: {
                WelcomeView(isFirstLaunch: whatsNewVersion == 0, appName: "My Assets", features: welcomeFeatures)
            })
            .environmentObject(financialData)
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
    }
}
