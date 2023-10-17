//
//  AssetView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-06.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct AssetView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    
    @Bindable var asset: Asset
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    @State private var showingLoan = false
    
    init(asset: Asset) {
        self.asset = asset
        _nameCopy = State(initialValue: asset.name ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $nameCopy)
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
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
                Button {
                    showingLoan = true
                } label: {
                    Label("Add", systemImage: "plus.circle")
                }
                ForEach(asset.loans ?? []) { loan in
                    NavigationLink(value: loan) {
                        AmountRow(symbol: loan.symbol ?? .defaultSymbol, label: loan.name ?? "", amount: loan.currentValue)
                    }
                }
                .onDelete(perform: delete)
                if let loans = asset.loans, let loansPaidFraction {
                    VStack {
                        ProgressView(value: loansPaidFraction)
                            .progressViewStyle(.linear)
                            .accessibilityHidden(true)
                        HStack {
                            Text("\(percentFormatter.string(from: NSNumber(value: loansPaidFraction)) ?? "") paid")
                            Spacer()
                            Text("\(loans.max(by: { $0.monthsToPayOff < $1.monthsToPayOff })?.monthsToPayOffString ?? "") left")
                        }
                    }
                    .padding(.vertical)
                }
            } header: {
                Text("Loans")
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
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: self.$showingLoan) {
            NavigationStack {
                NewDebtView(parentAsset: asset, debt: Debt(name: "\(asset.name ?? "") Loan", symbol: asset.symbol))
            }
        }
        .onDisappear {
            asset.name = nameCopy
        }
    }
    
    private var loansPaidFraction: Double? {
        guard let loans = asset.loans, !loans.isEmpty else { return nil }
        
        return max(0, asset.currentValue - loans.reduce(0, { $0 + $1.currentValue })) / asset.currentValue
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            if let loans = asset.loans {
                modelContext.delete(loans[offset])
            }
//            asset.loans.remove(at: offset)
        }
    }
    
}

struct AssetView_Previews: PreviewProvider {
    static var previews: some View {
        AssetView(asset: Asset())
    }
}
