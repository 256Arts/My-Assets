//
//  SettingsView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2022-04-09.
//  Copyright © 2022 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(UserDefaults.Key.userType) var userTypeValue = UserType.individual.rawValue
    @AppStorage(UserDefaults.Key.otherHouseholdNetWorth) var otherHouseholdNetWorth = 0.0
    @AppStorage(UserDefaults.Key.summaryScreenShowBalance) var summaryScreenShowBalance = true
    @AppStorage(UserDefaults.Key.summaryScreenShowNetWorth) var summaryScreenShowNetWorth = true
    @AppStorage(UserDefaults.Key.summaryScreenShowCashFlows) var summaryScreenShowCashFlows = true
    @AppStorage(UserDefaults.Key.summaryScreenShowInsights) var summaryScreenShowInsights = true
    
    @State var birthday = Date(timeIntervalSinceReferenceDate: UserDefaults.standard.double(forKey: UserDefaults.Key.birthday))
    
    var body: some View {
        Form {
            Section {
                Picker("User Type", selection: $userTypeValue) {
                    ForEach(UserType.allCases) { userType in
                        Text(userType.rawValue)
                            .tag(userType.rawValue)
                    }
                }
                DatePicker("Birthday", selection: $birthday, in: ...Date.now, displayedComponents: .date)
                if userTypeValue == UserType.individual.rawValue {
                    CurrencyField("Partner's Net Worth", value: $otherHouseholdNetWorth)
                }
            }
            
            Section("Summary Screen") {
                Toggle("Show Balance", isOn: $summaryScreenShowBalance)
                Toggle("Show Net Worth", isOn: $summaryScreenShowNetWorth)
                Toggle("Show Cash Flows", isOn: $summaryScreenShowCashFlows)
                Toggle("Show Insights", isOn: $summaryScreenShowInsights)
            }
            
            Section {
                Link(destination: URL(string: "https://www.256arts.com/")!) {
                    Label("Developer Website", systemImage: "safari")
                }
                Link(destination: URL(string: "https://www.256arts.com/joincommunity/")!) {
                    Label("Join Community", systemImage: "bubble.left.and.bubble.right")
                }
                Link(destination: URL(string: "https://github.com/256Arts/My-Assets")!) {
                    Label("Contribute on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }
            }
        }
        .navigationTitle("Settings")
        #if os(macOS)
        .scenePadding()
        #else
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
            
        }
        #endif
        .onChange(of: birthday) { _, newValue in
            UserDefaults.standard.set(newValue.timeIntervalSinceReferenceDate, forKey: UserDefaults.Key.birthday)
        }
    }
}

#Preview {
    SettingsView()
}
