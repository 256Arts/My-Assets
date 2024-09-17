//
//  AssetView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2020-02-06.
//  Copyright © 2020 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct AssetView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var data: FinancialData
    
    @Bindable var asset: Asset
    
    // Bug workaround: Editing name causes view to pop
    @State var nameCopy: String
    @State private var showingLoan = false
    @State private var showingSpend = false
    
    init(asset: Asset) {
        self.asset = asset
        _nameCopy = State(initialValue: asset.name ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                SymbolPickerLink(symbol: $asset.symbol)
                TextField("Name", text: $nameCopy)
                    #if !os(macOS)
                    .textInputAutocapitalization(.words)
                    #endif
                CurrencyField("Amount", value: $asset.currentValue)
                Toggle("Liquid", isOn: Binding(get: {
                    asset.isLiquid ?? true
                }, set: { newValue in
                    asset.isLiquid = newValue
                }))
                OptionalPercentField("Interest", value: $asset.annualInterestFraction)
                Picker("Compound Frequency", selection: $asset.compoundFrequency) {
                    ForEach(Asset.CompoundFrequency.allCases) { freq in
                        Text(freq.rawValue.capitalized)
                            .tag(freq as Asset.CompoundFrequency?)
                    }
                }
                if (asset.compoundFrequency ?? .monthly).timeInterval != .year {
                    Text("Effective Rate: \(percentFormatter.string(from: NSNumber(value: asset.effectiveAnnualInterestFraction))!)")
                }
            }
            
            switch asset.isLiquid {
            case true:
                Section("Upcoming Spends") {
                    ForEach(asset.upcomingSpends ?? []) { spend in
                        NavigationLink(value: spend) {
                            LabeledContent(spend.name ?? "", value: currencyFormatter.string(from: NSNumber(value: spend.cost ?? 0)) ?? "")
                        }
                    }
                    .onDelete(perform: deleteUpcomingSpend)
                    Button {
                        showingSpend = true
                    } label: {
                        Label("Add", systemImage: "plus.circle")
                    }
                    if let savingsForUpcomingSpendsFraction {
                        VStack {
                            ProgressView(value: savingsForUpcomingSpendsFraction)
                                .progressViewStyle(.linear)
                                .accessibilityHidden(true)
                            HStack {
                                Text("\(percentFormatter.string(from: NSNumber(value: savingsForUpcomingSpendsFraction)) ?? "") saved")
                                Spacer()
                            }
                        }
                        .padding(.vertical)
                    }
                }
            case false:
                Section("Loans") {
                    ForEach(asset.loans ?? []) { loan in
                        NavigationLink(value: loan) {
                            AmountRow(symbol: loan.symbol ?? .defaultSymbol, label: loan.name ?? "", amount: loan.currentValue)
                        }
                    }
                    .onDelete(perform: deleteLoan)
                    Button {
                        showingLoan = true
                    } label: {
                        Label("Add", systemImage: "plus.circle")
                    }
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
                }
            default:
                EmptyView()
            }
            
            if asset.income == nil, 0 < asset.monthlyEarnings {
                Section {
                    Label {
                        VStack(alignment: .leading) {
                            Text("There is no associated income for this asset.")
                            Button("Fix") {
                                try? asset.generateIncome()
                            }
                            .buttonStyle(.borderless)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                }
            }
        }
        .navigationTitle("Asset")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: self.$showingLoan) {
            NavigationStack {
                NewDebtView(parentAsset: asset, debt: Debt(name: "\(asset.name ?? "") Loan", symbol: asset.symbol ?? .defaultSymbol))
            }
        }
        .sheet(isPresented: self.$showingSpend) {
            NavigationStack {
                NewUpcomingSpendView(parentAsset: asset)
            }
        }
        .onDisappear {
            asset.name = nameCopy
            asset.income?.name = asset.name
            asset.income?.symbol = asset.symbol
            asset.income?.colorName = asset.colorName
            asset.income?.amount = asset.monthlyEarnings
            asset.income?.isLiquid = asset.isLiquid
        }
    }
    
    private var loansPaidFraction: Double? {
        guard let loans = asset.loans, !loans.isEmpty else { return nil }
        
        return max(0, asset.currentValue - loans.reduce(0, { $0 + $1.currentValue })) / asset.currentValue
    }
    
    private var savingsForUpcomingSpendsFraction: Double? {
        guard let spends = asset.upcomingSpends, !spends.isEmpty else { return nil }
        
        return max(0, min(asset.currentValue / spends.reduce(0, { $0 + ($1.cost ?? 0) }), 1))
    }
    
    private func deleteLoan(at offsets: IndexSet) {
        for offset in offsets {
            if let loans = asset.loans {
                modelContext.delete(loans[offset])
            }
        }
    }
    
    private func deleteUpcomingSpend(at offsets: IndexSet) {
        for offset in offsets {
            if let spends = asset.upcomingSpends {
                modelContext.delete(spends[offset])
            }
        }
    }
    
}

#Preview {
    AssetView(asset: Asset())
}
