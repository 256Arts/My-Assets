//
//  AssetView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-06.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct AssetView: View {
    
    @EnvironmentObject var data: FinancialData
    
    @Binding var asset: Asset
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    
    init(asset: Binding<Asset>) {
        _asset = asset
        _nameCopy = State(initialValue: asset.wrappedValue.name ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $nameCopy)
                    .textInputAutocapitalization(.words)
                DoubleField("Amount", value: $asset.currentValue, formatter: currencyFormatter)
                Toggle("Liquid", isOn: Binding(get: {
                    asset.isLiquid ?? true
                }, set: { newValue in
                    asset.isLiquid = newValue
                }))
            }
            Section {
                DoubleField("Interest", value: Binding(get: {
                    asset.annualInterestFraction ?? 0
                }, set: { newValue in
                    asset.annualInterestFraction = newValue
                }), formatter: percentFormatter)
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
        .navigationTitle("Asset")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            asset.name = nameCopy
            data.nonStockAssets.sort(by: >)
        }
    }
}

struct AssetView_Previews: PreviewProvider {
    static var previews: some View {
        AssetView(asset: .constant(Asset()))
    }
}
