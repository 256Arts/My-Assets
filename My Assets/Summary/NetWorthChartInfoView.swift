//
//  NetWorthChartInfoView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2023-10-28.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct NetWorthChartInfoView: View {
    
    @EnvironmentObject var data: FinancialData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Net Worth")
                        .font(.headline)
                    Text("Standard net worth calculation.")
                    Text("Income: \(currencyFormatter.string(from: NSNumber(value: data.totalIncome)) ?? "") Expenses: \(currencyFormatter.string(from: NSNumber(value: data.totalExpenses)) ?? "")")
                }
                
                VStack(alignment: .leading) {
                    Text("Natural")
                        .font(.headline)
                    Text("Only assets, debts, and interest on them. (No human interaction. No human work income, or human expenses.)")
                    Text("Income: \(currencyFormatter.string(from: NSNumber(value: data.totalPassiveIncome)) ?? "") Expenses: \(currencyFormatter.string(from: NSNumber(value: data.expenses.filter({ $0.fromDebt! }).reduce(0, { $0 + $1.monthlyCost }))) ?? "")")
                }
                
                VStack(alignment: .leading) {
                    Text("Quit Working")
                        .font(.headline)
                    Text("Net worth if you quit your job.")
                    Text("Income: \(currencyFormatter.string(from: NSNumber(value: data.totalPassiveIncome)) ?? "") Expenses: \(currencyFormatter.string(from: NSNumber(value: data.totalExpenses)) ?? "")")
                }
            }
        }
        .multilineTextAlignment(.leading)
        .scenePadding()
        .navigationTitle("Net Worth Graph Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
}

#Preview {
    NetWorthChartInfoView()
}
