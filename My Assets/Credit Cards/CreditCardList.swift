//
//  CreditCardList.swift
//  My Assets
//
//  Created by Jayden Irwin on 2024-08-10.
//  Copyright © 2024 Jayden Irwin. All rights reserved.
//

import SwiftData
import SwiftUI

struct CreditCardList: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var creditCards: [CreditCard]
    
    @State private var showingDetail: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(creditCards) { creditCard in
                    NavigationLink(value: creditCard) {
                        Label {
                            Text(creditCard.name ?? "")
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
                    Button(action: {
                        self.showingDetail.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                            .symbolVariant(.fill)
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
