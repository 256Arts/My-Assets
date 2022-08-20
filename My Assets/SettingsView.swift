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
    
    @State var birthday = Date(timeIntervalSinceReferenceDate: UserDefaults.standard.double(forKey: UserDefaults.Key.birthday))
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("User Type", selection: $userTypeValue) {
                        ForEach(UserType.allCases) { userType in
                            Text(userType.rawValue)
                                .tag(userType.rawValue)
                        }
                    }
                } footer: {
                    Text("Net worth percentiles are based on 2020 data from the USA, adjusted for inflation, and converted to your currency. If you are an individual, we assume your household has twice the net worth as you.")
                }
//                Section {
//                    DatePicker("Birthday", selection: $birthday, in: ...Date.now, displayedComponents: .date)
//                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: birthday) { newValue in
            UserDefaults.standard.set(newValue.timeIntervalSinceReferenceDate, forKey: UserDefaults.Key.birthday)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
