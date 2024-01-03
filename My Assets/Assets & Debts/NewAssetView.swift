//
//  NewAssetView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-06.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI
import JaydenCodeGenerator

struct NewAssetView: View {
    
    enum InterestInputMode {
        case direct, calculateWithPastValue
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var data: FinancialData
    
    @State var asset = Asset()
    @State var interestInputMode: InterestInputMode = .direct
    @State var interest: Double?
    @State var value1YearAgo: Double?
    @State var value: Double?
    @State var showingJaydenCode = false
    
    var jaydenCode: String {
        JaydenCodeGenerator.generateCode(secret: "T1HTN6HAKH")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: Binding(get: {
                    asset.name ?? ""
                }, set: { newValue in
                    asset.name = newValue
                })) {
                    if asset.name == "The World" {
                        showingJaydenCode = true
                    }
                }
                #if !os(macOS)
                .textInputAutocapitalization(.words)
                #endif
                OptionalDoubleField("Value ($)", value: $value, formatter: currencyFormatter)
                Toggle("Liquid", isOn: Binding(get: {
                    asset.isLiquid ?? true
                }, set: { newValue in
                    asset.isLiquid = newValue
                }))
            }
            Section {
                Picker("Interest Input Mode", selection: $interestInputMode) {
                    Text("Enter Interest")
                        .tag(InterestInputMode.direct)
                    Text("Find via Past Value")
                        .tag(InterestInputMode.calculateWithPastValue)
                }
                .pickerStyle(.segmented)
                if interestInputMode == .direct {
                    OptionalDoubleField("Annual Interest (%)", value: $interest, formatter: percentFormatter)
                } else {
                    OptionalDoubleField("Value 1 Year Ago ($)", value: $value1YearAgo, formatter: currencyFormatter)
                }
                Picker("Compound Frequency", selection: $asset.compoundFrequency) {
                    ForEach(Asset.CompoundFrequency.allCases) { freq in
                        Text(freq.rawValue.capitalized)
                            .tag(freq)
                    }
                }
                if (asset.compoundFrequency ?? .monthly).timeInterval != .year {
                    Text("Effective Rate: \(percentFormatter.string(from: NSNumber(value: asset.effectiveAnnualInterestFraction))!)")
                }
            } header: {
                Text("Interest")
            }
            Section {
                SymbolPicker(selected: Binding(get: {
                    asset.symbol ?? .defaultSymbol
                }, set: { newValue in
                    asset.symbol = newValue
                }))
            }
        }
        .navigationTitle("Add Asset")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if let value = self.value {
                        let interest = self.interest ?? 0.0
                        self.asset.annualInterestFraction = interest
                        self.asset.currentValue = value
                        modelContext.insert(asset)
                        self.data.nonStockAssets.append(self.asset)
                        self.dismiss()
                    }
                }
                .disabled(value == nil)
            }
        }
        .alert("Secret Code: \(jaydenCode)", isPresented: $showingJaydenCode) {
            Button("Copy") {
                #if canImport(UIKit)
                UIPasteboard.general.string = jaydenCode
                #endif
            }
            Button("OK", role: .cancel, action: { })
        }
        .onChange(of: value) { _, newValue in
            guard let value = newValue else { return }
            if let interest = interest {
                asset.annualInterestFraction = interest
                asset.currentValue = value
                value1YearAgo = asset.currentValue(at: Date().addingTimeInterval(-.year))
            } else if let cost = value1YearAgo {
                let ror = (value - cost) / cost
                interest = ror
            }
        }
        .onChange(of: interest) { _, newValue in
            guard let interest = newValue, let value = value else { return }
            asset.annualInterestFraction = interest
            asset.currentValue = value
            value1YearAgo = asset.currentValue(at: Date().addingTimeInterval(-.year))
        }
        .onChange(of: value1YearAgo) { _, newValue in
            guard let cost = newValue, let value = value else { return }
            let ror = (value - cost) / cost
            interest = ror
        }
        .onChange(of: asset.symbol) { _, newValue in
            if (asset.name ?? "").isEmpty {
                asset.name = newValue?.suggestedTitle
            }
        }
    }
}

struct NewAssetView_Previews: PreviewProvider {
    static var previews: some View {
        NewAssetView()
    }
}
