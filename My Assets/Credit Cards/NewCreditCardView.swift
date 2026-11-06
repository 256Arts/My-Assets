import SwiftUI
import StoreKit

struct NewCreditCardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) private var requestReview
    
    @State var creditCard = CreditCard()
    
    var body: some View {
        List {
            Section {
                TextField("Name", text: Binding(get: {
                    creditCard.name ?? ""
                }, set: { newValue in
                    creditCard.name = newValue
                }))
                ColorPickerLink(colorName: $creditCard.colorName)
                TextEditor(text: Binding(get: {
                    creditCard.notes ?? ""
                }, set: { newValue in
                    creditCard.notes = newValue
                }))
            }
            CreditCardRewardsSections(creditCard: creditCard)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    self.dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    modelContext.insert(creditCard)
                    if UserDefaults.standard.incrementItemsCreated() { requestReview() }
                    self.dismiss()
                }
                .disabled(creditCard.name?.isEmpty != false)
            }
        }
        .navigationTitle("New Credit Card")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NewCreditCardView(creditCard: CreditCard())
}
