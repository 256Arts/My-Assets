import SwiftUI

/// The spending and rewards fields shared by the new and edit credit card screens.
struct CreditCardRewardsSections: View {
    
    @Bindable var creditCard: CreditCard
    
    @State private var showingNewCategory = false
    
    private var hasCategories: Bool {
        !(creditCard.spendingCategories ?? []).isEmpty
    }
    
    var body: some View {
        Section {
            OptionalCurrencyField(hasCategories ? "Other Monthly Spend" : "Monthly Spend", value: $creditCard.monthlySpend)
            PointsPerDollarField(hasCategories ? "Other Points/$" : "Points/$", value: $creditCard.pointsPerDollar)
            ForEach(creditCard.sortedSpendingCategories) { category in
                NavigationLink {
                    SpendingCategoryView(category: category)
                } label: {
                    SpendingCategoryRow(category: category)
                }
            }
            .onDelete(perform: deleteCategories)
            Button("Add Category", systemImage: "plus") {
                showingNewCategory = true
            }
            .sheet(isPresented: $showingNewCategory) {
                NavigationStack {
                    NewSpendingCategoryView(creditCard: creditCard)
                }
            }
        } header: {
            Text("Spending")
        } footer: {
            Text("Add a category for purchases that earn a different rate, like dining or groceries.")
        }
        Section {
            OptionalCurrencyField("Card Fee (Yearly)", value: $creditCard.cardFee)
            LabeledContent("Point Value") {
                TextField("", value: $creditCard.pointValue, format: .number)
                    .multilineTextAlignment(.trailing)
                    #if !os(macOS)
                    .keyboardType(.decimalPad)
                    #endif
            }
            Picker("Reward Type", selection: $creditCard.rewardType) {
                Text("Cash")
                    .tag(CreditCard.RewardType.cash)
                Text("Gift Cards")
                    .tag(CreditCard.RewardType.giftCard)
            }
            LabeledContent("Minimum Redemption (Points)") {
                TextField("", value: $creditCard.minimumRedemption, format: .number)
                    .multilineTextAlignment(.trailing)
                    #if !os(macOS)
                    .keyboardType(.numberPad)
                    #endif
            }
            if creditCard.rewardType == .giftCard {
                LabeledContent("Time Holding Gift Card (Months)") {
                    TextField("", value: $creditCard.timeHoldingGiftCard, format: .number)
                        .multilineTextAlignment(.trailing)
                        #if !os(macOS)
                        .keyboardType(.decimalPad)
                        #endif
                }
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        let categories = creditCard.sortedSpendingCategories
        for offset in offsets {
            let category = categories[offset]
            creditCard.spendingCategories?.removeAll { $0 === category }
            // A card still being created has no context yet.
            category.modelContext?.delete(category)
        }
    }
}

private struct SpendingCategoryRow: View {
    
    let category: SpendingCategory
    
    var body: some View {
        LabeledContent {
            Text("\((category.pointsPerDollar ?? 0).formatted()) pts/$")
        } label: {
            Text(category.name ?? "")
            Text("\(currencyFormatter.string(from: NSNumber(value: category.monthlySpend ?? 0))!)/month")
        }
    }
}

struct PointsPerDollarField: View {
    
    let label: LocalizedStringKey
    @Binding var value: Double?
    
    init(_ label: LocalizedStringKey, value: Binding<Double?>) {
        self.label = label
        _value = value
    }
    
    var body: some View {
        LabeledContent(label) {
            TextField("", value: $value, format: .number)
                .multilineTextAlignment(.trailing)
                #if !os(macOS)
                .keyboardType(.decimalPad)
                #endif
        }
    }
}
