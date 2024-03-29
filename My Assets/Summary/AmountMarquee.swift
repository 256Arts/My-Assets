//
//  AmountMarquee.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2022-02-16.
//  Copyright © 2022 256 Arts Developer. All rights reserved.
//

import SwiftUI

struct AmountMarquee: View {
    
    @Binding var period: Period
    @Binding var showAsCombinedValue: Bool
    
    @State var currentValue: Double
    @State var monthlyIncome: Double
    @State var monthlyExpenses: Double
    
    var combinedNet: Double {
        (monthlyIncome - monthlyExpenses) * period.months
    }
    
    var tertiaryLabel: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor.tertiaryLabel)
        #else
        Color(nsColor: NSColor.tertiaryLabelColor)
        #endif
    }
    
    var body: some View {
        VStack {
            Text(currencyFormatter.string(from: NSNumber(value: currentValue))!)
                .font(Font.system(size: 40, weight: .semibold, design: .rounded))
                .padding(.vertical)
            
            if showAsCombinedValue {
                VStack {
                    Text(currencyDeltaFormatter.string(from: NSNumber(value: combinedNet))!)
                        .font(Font.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundColor(0 < combinedNet ? .green : .red)
                    Text("\(period.rawValue) Net")
                        .font(.caption)
                        .foregroundColor(tertiaryLabel)
                }
            } else {
                HStack {
                    VStack {
                        Text(currencyDeltaFormatter.string(from: NSNumber(value: monthlyIncome * period.months))!)
                            .font(Font.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.green)
                            .accessibilityLabel("\(period.rawValue) Income")
                        Text("\(period.rawValue) Income")
                            .font(.caption)
                            .foregroundColor(tertiaryLabel)
                            .accessibilityHidden(true)
                    }
                    Spacer()
                    VStack {
                        Text(currencyDeltaFormatter.string(from: NSNumber(value: -monthlyExpenses * period.months))!)
                            .font(Font.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                            .accessibilityLabel("\(period.rawValue) Expenses")
                        Text("\(period.rawValue) Expenses")
                            .font(.caption)
                            .foregroundColor(tertiaryLabel)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity)
        
    }
}

#Preview {
    AmountMarquee(period: .constant(.month), showAsCombinedValue: .constant(false), currentValue: 5000, monthlyIncome: 2000, monthlyExpenses: 1000)
}
