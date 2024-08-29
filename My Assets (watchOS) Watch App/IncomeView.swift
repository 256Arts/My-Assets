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
    
    @EnvironmentObject var data: FinancialData
    
    @Query(sort: [SortDescriptor(\Income.monthlyEarnings, order: .reverse)]) var incomes: [Income]
    
    var body: some View {
        List {
            ForEach(incomes) { income in
                AmountRow(symbol: income.symbol ?? .defaultSymbol, label: income.name!, amount: income.monthlyEarnings ?? 0)
            }
            ForEach(data.income.filter({ $0.fromAsset && $0.isLiquid! })) { income in
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
