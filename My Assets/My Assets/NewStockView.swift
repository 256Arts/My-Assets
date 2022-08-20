//
//  NewStockView.swift
//  My Assets
//
//  Created by Jayden Irwin on 2020-02-06.
//  Copyright © 2020 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct NewStockView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var data: FinancialData
    
    @State var stockSymbol = ""
    @State var stockShares = 0
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Symbol", text: $stockSymbol)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                TextField("Number Of Shares", value: $stockShares, formatter: NumberFormatter())
            }
                .navigationTitle("Add Stock")
                .navigationBarItems(leading: Button(action: {
                    self.dismiss()
                }, label: {
                    Text("Cancel")
                }), trailing: Button(action: {
                    let stock = Stock(symbol: self.stockSymbol, shares: self.stockShares)
                    stock.fetchPrices()
                    self.data.stocks.append(stock)
                    self.dismiss()
                }, label: {
                    Text("Done")
                }))
        }
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct NewStockView_Previews: PreviewProvider {
    static var previews: some View {
        NewStockView()
    }
}
