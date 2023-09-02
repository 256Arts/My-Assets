//
//  RootTabView.swift
//  My Assets (watchOS) Watch App
//
//  Created by Jayden Irwin on 2023-07-28.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftData
import SwiftUI

struct RootTabView: View {
    
    @Query var assets: [Asset]
    @Query var debts: [Debt]
    @Query var stocks: [Stock]
    @Query var nonAssetIncome: [Income]
    @Query var nonDebtExpenses: [Expense]
    
    var body: some View {
        TabView {
            MyAssetsView()
        }
        .environmentObject(financialData)
    }
    
    private var financialData: FinancialData {
        FinancialData(nonStockAssets: assets, stocks: stocks, debts: debts, nonAssetIncome: nonAssetIncome, nonDebtExpenses: nonDebtExpenses)
    }
}

#Preview {
    RootTabView()
}
