//
//  SummaryView.swift
//  My Assets (watchOS) Watch App
//
//  Created by Jayden Irwin on 2023-11-07.
//  Copyright © 2023 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct SummaryView: View {
    
    @EnvironmentObject var data: FinancialData
    
    var body: some View {
        List {
            LabeledContent("Balance", value: currencyFormatter.string(from: NSNumber(value: data.balance(at: .now))) ?? "")
            
            LabeledContent("Net Worth", value: currencyFormatter.string(from: NSNumber(value: data.netWorth(at: .now, type: .working))) ?? "")
        }
        .navigationTitle("Summary")
    }
}

#Preview {
    SummaryView()
}
