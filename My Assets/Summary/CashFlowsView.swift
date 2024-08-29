//
//  CashFlowsView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2024-08-26.
//  Copyright © 2024 Jayden Irwin. All rights reserved.
//

import SwiftData
import SwiftUI

struct CashFlowsView: View {
    
    private struct Transaction: Identifiable {
        let name: String
        let transactionAmount: Double
        let nextTransactionDate: Date
        
        var id: String { name + String(transactionAmount) + nextTransactionDate.description }
    }
    
    @EnvironmentObject var data: FinancialData
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
                guard let name = $0.name, let transactionAmount = $0.transactionAmount, let nextTransactionDate = $0.nextTransactionDate else { return nil }
                
                return Transaction(name: name, transactionAmount: transactionAmount, nextTransactionDate: nextTransactionDate)
            }
            .sorted { $0.nextTransactionDate < $1.nextTransactionDate }
    }
    
    var body: some View {
        ForEach(upcomingTransactions) { trans in
            HStack {
                Image(systemName: trans.transactionAmount < 0 ? "tray.and.arrow.up" : "tray.and.arrow.down")
                    .foregroundStyle(trans.transactionAmount < 0 ? Color.red : Color.green)
                
                Text(dateFormatter.string(from: trans.nextTransactionDate))
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(currencyFormatter.string(from: NSNumber(value: trans.transactionAmount)) ?? "")
                        .foregroundStyle(trans.transactionAmount < 0 ? Color.red : Color.green)
                    Text(trans.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    CashFlowsView()
}
