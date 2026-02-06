//
//  SummaryView.swift
//  My Assets (watchOS) Watch App
//
//  Created by 256 Arts Developer on 2023-11-07.
//  Copyright © 2023 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct SummaryView: View {
    
    @Environment(FinancialData.self) private var data
    
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
