//
//  InsightsGenerator.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2022-04-09.
//  Copyright © 2022 256 Arts Developer. All rights reserved.
//

import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

final class InsightsGenerator {
    
    init(data: FinancialData) {
        self.data = data
    }
    
    let data: FinancialData
    
    var avgAnnualAssetsInterest: Double {
        // Uses weighted average
        let totalAssets = data.assets.filter({ $0.isLiquid! }).reduce(0.0, { $0 + $1.currentValue }) // Excludes debts
        let avgAnnualAssetInterest = data.assets.filter({ $0.isLiquid! }).reduce(0.0, { $0 + $1.effectiveAnnualInterestFraction * ($1.currentValue / totalAssets) })
        let avgAnnualDebtInterest = data.debts.reduce(0.0, { $0 + $1.annualInterestFraction! * ($1.currentValue / totalAssets) })
        return avgAnnualAssetInterest - avgAnnualDebtInterest
    }
    var avgAnnualBalanceInterest: Double {
        let interest = (data.balance(at: Date(timeIntervalSinceNow: .year)) / data.balance(at: .now)) - 1.0
        return interest.isFinite ? interest : 0
    }
    var liveOffMonths: Double {
        // Note: We only care about liquid values in this entire func.
        guard 0 < data.balance(at: .now) else { return 0.0 }
        
        let passiveIncome = data.income.filter { $0.isPassive == true && $0.isLiquid == true }
        let totalPassiveIncome = passiveIncome.reduce(0.0, { $0 + ($1.monthlyEarnings ?? 0) })
        guard totalPassiveIncome < data.totalExpenses else { return .infinity }
        
        // Static = Same amount every month
        // Exclude debt interest since it's included in `avgAnnualBalanceInterest`
        let totalStaticExpenses = data.expenses.filter { $0.fromDebt == nil }.reduce(0.0, { $0 + $1.monthlyCost(excludingSavings: true) })
        // Exclude asset interest since it's included in `avgAnnualBalanceInterest`
        let totalStaticPassiveIncome = passiveIncome.filter({ $0.fromAsset == nil }).reduce(0.0, { $0 + ($1.monthlyEarnings ?? 0) })
        let staticMonthlyDrain = totalStaticExpenses - totalStaticPassiveIncome

        let p = data.balance(at: .now) // Principal value
        let r = avgAnnualBalanceInterest // Rate

        // With no balance interest the log-based formula divides by zero, so fall back to a flat drain.
        guard !r.isZero else {
            return 0 < staticMonthlyDrain ? p / staticMonthlyDrain : .infinity
        }

        // Dynamic = Different amount every month based on interest percentages
        /* Using formulas:
         - Compound interest
         - Future value of a series
         Note: We get the formula below by solving for t.
        */
        let a = 0.0 // Future value
        let n = 12.0 // Compounds per time unit
        let m = -staticMonthlyDrain // Monthly payment
        let t = log((a * r + n * m) / (p * r + n * m)) / (n * log(1 + r / n))

        return t * 12
    }
    var retirementDate: Date? {
        let birthdayTimeSinceReference = UserDefaults.standard.double(forKey: UserDefaults.Key.birthday)
        
        guard birthdayTimeSinceReference != 0 else { return nil }
        
        let birthday = Date(timeIntervalSinceReferenceDate: birthdayTimeSinceReference)
        return birthday + (65 * .year)
    }
    var retirementBalance: Double? {
        guard let retirementDate = retirementDate, 0 < retirementDate.timeIntervalSinceNow else { return nil }
        
        return data.balance(at: retirementDate)
    }
    
    func netWorthPercentile() -> Double? {
        let userType = UserType(rawValue: UserDefaults.standard.string(forKey: UserDefaults.Key.userType) ?? "") ?? .individual
        let otherHouseholdNetWorth = (userType == .individual ? UserDefaults.standard.double(forKey: UserDefaults.Key.otherHouseholdNetWorth) : 0)
        let householdNetWorth = data.netWorth(at: .now, type: .working) + otherHouseholdNetWorth
        return netWorthPercentile(householdNetWorth: householdNetWorth, at: .now, locale: .current)
    }
    func netWorthPercentile(householdNetWorth: Double, at date: Date, locale: Locale) -> Double? {
        guard let conversionRate = WorldFinanceStats.conversionRates[locale.currency?.identifier ?? ""] else { return nil }
        
        let myNetWorth = householdNetWorth * conversionRate
        var myBracket = WorldFinanceStats.Bracket(percentile: 0.0, money: myNetWorth)
        
        for bracket in WorldFinanceStats.usHouseholdNetWorthPercentiles(at: date) {
            if myNetWorth < bracket.money {
                let fractionToBracket = (myNetWorth - myBracket.money) / (bracket.money - myBracket.money)
                let percentile = myBracket.percentile + (fractionToBracket * (bracket.percentile - myBracket.percentile))
                myBracket = .init(percentile: percentile, money: myNetWorth)
                break
            } else {
                myBracket = bracket
            }
        }
        return myBracket.percentile
    }
    
    // Strings
    var avgAnnualAssetsInterestString: String {
        percentFormatter.string(from: NSNumber(value: avgAnnualAssetsInterest))!
    }
    var avgAnnualBalanceInterestString: String {
        percentFormatter.string(from: NSNumber(value: avgAnnualBalanceInterest))!
    }
    var avgAnnualNetWorthInterestString: String {
        percentFormatter.string(from: NSNumber(value: data.avgAnnualNetWorthInterest))!
    }
    var balanceIn5YearsString: String {
        currencyFormatter.string(from: NSNumber(value: data.balance(at: .now + 5 * TimeInterval.year)))!
    }
    var netWorthIn5YearsString: String {
        currencyFormatter.string(from: NSNumber(value: data.netWorth(at: .now + 5 * TimeInterval.year, type: .working)))!
    }
    var retirementBalanceString: String? {
        guard let retirementBalance = retirementBalance else { return nil }

        return currencyFormatter.string(from: NSNumber(value: retirementBalance))!
    }
    var adjustedRetirementBalanceString: String? {
        guard let retirementBalance = retirementBalance, let retirementDate = retirementDate else { return nil }

        return currencyFormatter.string(from: NSNumber(value: WorldFinanceStats.adjustForInflation(value: retirementBalance, in: retirementDate)))!
    }
    var liveOffTimeString: String {
        guard !liveOffMonths.isInfinite, !liveOffMonths.isNaN else { return "forever" }
        let liveOffTime = DateComponents(day: Int(liveOffMonths * 30))
        return timeRemainingFormatter.string(from: liveOffTime) ?? "unknown"
    }
    var requiredBalanceToLiveOffString: String? {
        guard 0 < avgAnnualBalanceInterest else { return nil }
        
        let totalStaticExpenses = data.expenses.filter { $0.fromDebt == nil }.reduce(0.0, { $0 + $1.monthlyCost(excludingSavings: true) })
        let totalStaticPassiveIncome = data.income.filter { $0.isPassive! && $0.fromAsset == nil }.reduce(0.0, { $0 + ($1.monthlyEarnings ?? 0) })
        let staticMonthlyDrain = totalStaticExpenses - totalStaticPassiveIncome
        
        let requiredNewAssets = staticMonthlyDrain / (avgAnnualBalanceInterest / 12)
        return currencyFormatter.string(from: NSNumber(value: data.balance(at: .now) + requiredNewAssets))!
    }
    var netWorthPercentileString: String? {
        guard let netWorthPercentile = netWorthPercentile() else { return nil }
        
        if netWorthPercentile < 0.5 {
            return "Bottom \(percentFormatter.string(from: NSNumber(value: netWorthPercentile))!)"
        } else {
            return "Top \(percentFormatter.string(from: NSNumber(value: 1 - netWorthPercentile))!)"
        }
    }
    
    func generate() -> [AttributedString] {
        var insights: [AttributedString] = []
        
        let month = Calendar.current.dateComponents([.month], from: .now).month
        switch month {
        case 1:
            insights.append("Selling assets in January will defer your tax expense.")
        case 11, 12:
            insights.append("Waiting until January to sell assets will defer your tax expense.")
            insights.append("If you expect to be in a higher tax bracket next year, selling assets before January locks in this year's lower rate.")
        default:
            break
        }
        
        if !data.expenses.isEmpty {
            if 0 < liveOffMonths {
                let earningNetWorthViaAssets = !data.income.filter { $0.isPassive! && $0.fromAsset != nil }.isEmpty
                insights.append(try! AttributedString(markdown: "You could live off your \(earningNetWorthViaAssets ? "assets" : "passive income") for **\(liveOffTimeString)**."))
            }
            if liveOffTimeString != "forever", let requiredBalanceToLiveOffString = requiredBalanceToLiveOffString {
                insights.append(try! AttributedString(markdown: "You need **\(requiredBalanceToLiveOffString)** to live off of your passive income forever."))
            }
        }
        
        if let retirementBalanceString = retirementBalanceString, let adjustedRetirementBalanceString = adjustedRetirementBalanceString {
            insights.append(try! AttributedString(markdown: "At retirement, your balance could be **\(retirementBalanceString)**. (**\(adjustedRetirementBalanceString)** adjusted for inflation.)"))
        }
        
        if !avgAnnualBalanceInterest.isZero, let interestString = percentFormatter.string(from: NSNumber(value: avgAnnualBalanceInterest * (1.5 / 12))) {
            insights.append(try! AttributedString(markdown: "Defering payment through a credit card can earn you **\(interestString)** in interest"))
        }
        
        return insights
    }

    /// A compact, plain-language snapshot of the user's finances, fed to the on-device
    /// model as grounding context for custom insights. Only includes figures the app
    /// already computes — the model is instructed never to invent numbers beyond these.
    var financialSummary: String {
        func money(_ value: Double) -> String {
            currencyFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
        func percent(_ value: Double) -> String {
            percentFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }

        var lines: [String] = []
        lines.append("Net worth: \(money(data.netWorth(at: .now, type: .working)))")
        lines.append("Liquid balance: \(money(data.balance(at: .now)))")
        lines.append("Projected net worth in 5 years: \(netWorthIn5YearsString)")
        lines.append("Year-over-year net worth growth (return on equity, leverage-aware): \(percent(data.avgAnnualNetWorthInterest))")
        lines.append("Blended annual yield across all assets: \(percent(data.avgAnnualSavingsInterest))")
        lines.append("Monthly income: \(money(data.totalIncome)) (of which passive: \(money(data.totalPassiveIncome)))")
        lines.append("Monthly expenses: \(money(data.totalExpenses))")
        if !liveOffMonths.isNaN {
            lines.append("Could live off savings / passive income for: \(liveOffTimeString)")
        }
        if let percentile = netWorthPercentileString {
            lines.append("Household net worth ranking: \(percentile)")
        }
        return lines.joined(separator: "\n")
    }

}

#if canImport(FoundationModels)

/// Structured output for the on-device model: a short list of insight strings.
@Generable
struct GeneratedInsights {
    @Guide(description: "Three or four distinct, specific insights about the user's long-term financial trajectory. Each is one or two sentences.")
    var insights: [String]
}

/// Generates personalized, long-term financial insights on-device via Apple Intelligence
/// (the Foundation Models framework). Financial data never leaves the device.
@MainActor
@Observable
final class AIInsightsGenerator {

    enum Phase {
        case idle
        case generating
        case loaded([String])
        case unavailable(String)
        case failed(String)
    }

    private(set) var phase: Phase = .idle

    private static let instructions = """
    You are a financial insights assistant inside "My Assets", a birds-eye net-worth app \
    focused on long-term wealth strategy — not day-to-day budgeting.

    Given a snapshot of the user's finances, surface three or four distinct insights about \
    their long-term trajectory. Follow these rules:
    - Think big-picture and multi-year: how net worth compounds, the effect of leverage, \
    savings rate, passive income, and time horizon.
    - Ground every statement only in the figures provided. Never invent numbers, percentages, \
    or facts that are not in the snapshot.
    - Be specific to this user's situation. Avoid generic tips like "make a budget" or "spend less".
    - Keep each insight to one or two sentences, concrete and strategic.
    - Be direct and encouraging. Do not add disclaimers or hedging.
    """

    /// Generates insights from a financial summary, unless a generation has already
    /// succeeded or is in flight. Use `regenerate(summary:)` to force a refresh.
    func generateIfNeeded(summary: String) async {
        if case .idle = phase {
            await regenerate(summary: summary)
        }
    }

    func regenerate(summary: String) async {
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(.deviceNotEligible):
            phase = .unavailable("This device doesn't support Apple Intelligence.")
            return
        case .unavailable(.appleIntelligenceNotEnabled):
            phase = .unavailable("Turn on Apple Intelligence in Settings to see custom insights.")
            return
        case .unavailable(.modelNotReady):
            phase = .unavailable("Apple Intelligence is preparing its model. Try again shortly.")
            return
        case .unavailable:
            phase = .unavailable("Apple Intelligence is currently unavailable.")
            return
        }

        phase = .generating
        do {
            let session = LanguageModelSession(instructions: Self.instructions)
            let prompt = """
            Here is the user's current financial snapshot:

            \(summary)

            Generate the insights now.
            """
            let response = try await session.respond(to: prompt, generating: GeneratedInsights.self)
            let cleaned = response.content.insights
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if cleaned.isEmpty {
                phase = .failed("No insights were generated.")
            } else {
                phase = .loaded(Array(cleaned.prefix(4)))
            }
        } catch {
            phase = .failed("Couldn't generate custom insights right now.")
        }
    }

}

#endif
