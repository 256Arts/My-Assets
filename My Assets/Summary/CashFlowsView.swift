//
//  CashFlowsView.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2024-08-26.
//  Copyright © 2024 256 Arts Developer. All rights reserved.
//

import SwiftData
import SwiftUI

struct CashFlowsView: View {
    
    private struct Transaction: Identifiable {
        let name: String
        let amount: Double
        let nextTransactionDate: Date
        
        var id: String { name + String(amount) + nextTransactionDate.description }
    }
    
    @Environment(FinancialData.self) private var data
    @Query var upcomingSpends: [UpcomingSpend]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "MMMM d"
        return formatter
    }()
    private var upcomingTransactions: [Transaction] {
        let all: [any Schedulable] = (data.income + data.expenses + upcomingSpends)
        return all
            .compactMap {
                guard let name = $0.name, let transactionAmount = $0.amount, let nextTransactionDate = $0.nextTransactionDate else { return nil }
                
                return Transaction(name: name, amount: transactionAmount, nextTransactionDate: nextTransactionDate)
            }
            .sorted { $0.nextTransactionDate < $1.nextTransactionDate }
    }
    
    var body: some View {
        if upcomingTransactions.isEmpty {
            Text("No incomes/expenses scheduled with a starting date.")
                .foregroundStyle(.secondary)
        } else {
            ForEach(upcomingTransactions) { trans in
                HStack {
                    Image(systemName: trans.amount < 0 ? "tray.and.arrow.up" : "tray.and.arrow.down")
                        .foregroundStyle(trans.amount < 0 ? Color.red : Color.green)
                    
                    Text(dateFormatter.string(from: trans.nextTransactionDate))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(currencyDeltaFormatter.string(from: NSNumber(value: trans.amount)) ?? "")
                            .foregroundStyle(trans.amount < 0 ? Color.red : Color.green)
                        Text(trans.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    CashFlowsView()
}
