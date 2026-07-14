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
