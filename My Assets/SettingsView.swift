//
//  SettingsView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2022-04-09.
//  Copyright © 2022 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(UserDefaults.Key.userType) var userTypeValue = UserType.individual.rawValue
    @AppStorage(UserDefaults.Key.otherHouseholdNetWorth) var otherHouseholdNetWorth = 0.0
    #if DEBUG
    @AppStorage(UserDefaults.Key.showDebugData) var showDebugData = false {
        didSet {
            exit(0) // Quit app to reset `CloudController`
        }
    }
    #endif
    
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
                if userTypeValue == UserType.individual.rawValue {
                    DoubleField("Partner's Net Worth", value: $otherHouseholdNetWorth, formatter: NumberFormatter())
                }
            } footer: {
                Text("Net worth percentiles are based on 2020 data from the USA, adjusted for inflation, and converted to your currency.")
            }
            
            Section {
                DatePicker("Birthday", selection: $birthday, in: ...Date.now, displayedComponents: .date)
            }
            
            #if DEBUG
            Section {
                Toggle("Debug Data", isOn: $showDebugData)
            }
            #endif
            
            Section {
                Link(destination: URL(string: "https://www.jaydenirwin.com/")!) {
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
