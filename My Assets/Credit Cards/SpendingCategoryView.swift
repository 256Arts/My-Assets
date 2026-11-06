import SwiftUI

private struct SpendingCategoryFields: View {
    
    @Bindable var category: SpendingCategory
    
    var body: some View {
        Section {
            TextField("Name", text: Binding(get: {
                category.name ?? ""
            }, set: { newValue in
                category.name = newValue
            }))
            OptionalCurrencyField("Monthly Spend", value: $category.monthlySpend)
            PointsPerDollarField("Points/$", value: $category.pointsPerDollar)
        }
    }
}

struct SpendingCategoryView: View {
    
    let category: SpendingCategory
    
    var body: some View {
        List {
            SpendingCategoryFields(category: category)
        }
        .navigationTitle("Category")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct NewSpendingCategoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let creditCard: CreditCard
    
    @State private var category = SpendingCategory()
    
    var body: some View {
        List {
            SpendingCategoryFields(category: category)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    creditCard.spendingCategories = (creditCard.spendingCategories ?? []) + [category]
                    dismiss()
                }
                .disabled(category.name?.isEmpty != false)
            }
        }
        .navigationTitle("New Category")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        NewSpendingCategoryView(creditCard: CreditCard())
    }
}
