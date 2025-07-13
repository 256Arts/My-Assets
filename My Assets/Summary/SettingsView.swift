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
        }
        .navigationTitle("Settings")
        #if os(macOS)
        .scenePadding()
        #else
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", systemImage: "checkmark") {
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
