//
//  CreditCardList.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2024-08-10.
//  Copyright © 2024 256 Arts Developer. All rights reserved.
//

import SwiftData
import SwiftUI

struct CreditCardList: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(FinancialData.self) private var data
    
    @Query(sort: [SortDescriptor(\CreditCard.name)]) var creditCards: [CreditCard]
    
    @State private var showingDetail: Bool = false
    
    var insights: InsightsGenerator {
        .init(data: data)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(creditCards) { creditCard in
                    NavigationLink(value: creditCard) {
                        Label {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(creditCard.name ?? "")
                                    Spacer()
                                    if let rewardsRate = creditCard.rewardsRate(avgAnnualBalanceInterest: insights.avgAnnualBalanceInterest) {
                                        Text(percentFormatter.string(from: NSNumber(value: rewardsRate))!)
                                    }
                                }
                                
                                if let notes = creditCard.notes {
                                    Text(notes)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "creditcard")
                                .symbolVariant(.fill)
                                .foregroundStyle(creditCard.colorName?.color ?? .gray)
                        }
                    }
                }
                .onDelete { offsets in
                    for offset in offsets {
                        modelContext.delete(creditCards[offset])
                    }
                }
            }
            .navigationTitle("Credit Cards")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") {
                        self.showingDetail.toggle()
                    }
                }
            }
            .navigationDestination(for: CreditCard.self) { creditCard in
                CreditCardView(creditCard: creditCard)
            }
        }
        .sheet(isPresented: self.$showingDetail) {
            NavigationStack {
                NewCreditCardView()
            }
        }
    }
}

#Preview {
    CreditCardList()
}
