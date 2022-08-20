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
        _nameCopy = State(initialValue: asset.wrappedValue.name)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $nameCopy)
                    .textInputAutocapitalization(.words)
                DoubleField("Amount", value: $asset.currentValue, formatter: currencyFormatter)
                Toggle("Liquid", isOn: $asset.isLiquid)
            }
            Section {
                DoubleField("Interest", value: $asset.annualInterestFraction, formatter: percentFormatter)
                Picker("Compound Frequency", selection: $asset.compoundFrequency) {
                    ForEach(Asset.CompoundFrequency.allCases) { freq in
                        Text(freq.rawValue.capitalized)
                            .tag(freq)
                    }
                }
                if asset.compoundFrequency.timeInterval != .year {
                    Text("Effective Rate: \(percentFormatter.string(from: NSNumber(value: asset.effectiveAnnualInterestFraction))!)")
                }
            } header: {
                Text("Interest")
            }
            Section {
                SymbolPicker(selected: $asset.symbol)
            }
        }
        .navigationTitle(nameCopy)
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
