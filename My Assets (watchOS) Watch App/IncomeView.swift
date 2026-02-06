//
//  IncomeView.swift
//  My Assets (watchOS) Watch App
//
//  Created by 256 Arts Developer on 2023-09-02.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftUI
import SwiftData

struct IncomeView: View {
    
    @Environment(FinancialData.self) private var data
    
    @Query(sort: [SortDescriptor(\Income.amount, order: .reverse)]) var incomes: [Income]
    
    var body: some View {
        List {
            ForEach(incomes.filter({ $0.fromAsset == nil })) { income in
                AmountRow(symbol: income.symbol ?? .defaultSymbol, label: income.name!, amount: income.monthlyEarnings ?? 0)
            }
            ForEach(incomes.filter({ $0.fromAsset != nil && $0.isLiquid! })) { income in
                AmountRow(symbol: income.symbol ?? .defaultSymbol, label: income.name!, amount: income.monthlyEarnings ?? 0)
            }
            HStack {
                Text("Total")
                Spacer()
                Text(currencyFormatter.string(from: NSNumber(value: data.totalLiquidIncome))!)
            }
                .font(Font.headline)
                .accessibilityElement()
                .accessibilityLabel("Total")
                .accessibilityValue(currencyFormatter.string(from: NSNumber(value: data.totalLiquidIncome))!)
        }
        .navigationTitle("Income")
    }
}

#Preview {
    IncomeView()
}
