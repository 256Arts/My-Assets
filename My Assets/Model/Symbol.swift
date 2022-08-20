//
//  Symbol.swift
//  My Assets
//
//  Created by Jayden Irwin on 2021-10-27.
//  Copyright © 2021 Jayden Irwin. All rights reserved.
//

import SwiftUI

enum Symbol: String, CaseIterable, Identifiable, Codable {
    // Generic
    case banknote
    case bitcoin = "bitcoinsign.circle"
    case creditcard, bag, gift
    case bank = "building.columns"
    case stocks = "chart.line.uptrend.xyaxis" // Future: Hide this option when adding native stocks support in app
    
    // Living
    case house, building, car, fuelpump, bus, tram, airplane, sailboat
    case bed = "bed.double"
    
    // Household
    case wifi, flame, snowflake, drop, bolt, hammer, wrench, lightbulb
    case chair = "chair.lounge"
    case basket
    
    // Other
    case wineglass
    case pills
    case stethoscope
    case pawprint, teddybear, leaf, graduationcap
    case doc = "doc.text"
    case ticket
    case takeoutbag = "takeoutbag.and.cup.and.straw"
    case tshirt, shippingbox, iphone
    
    // Digital
    case icloud
    case music = "music.note"
    case tv, gamecontroller, newspaper
    case figure = "figure.arms.open"
    case figurerun = "figure.run"
    case family = "figure.2.and.child.holdinghands"
    case app = "app.badge"
    
    // Shapes
    case star
    
    static let defaultSymbol = Symbol.banknote
    
    var id: Self { self }
    
    var suggestedTitle: String {
        switch self {
        case .banknote:
            return "Cash"
        case .bitcoin:
            return "Bitcoin"
        case .creditcard:
            return "Credit Card"
        case .bag:
            return "Shopping"
        case .gift:
            return "Gifts"
        case .bank:
            return "Bank Account"
        case .stocks:
            return "Stocks"
        case .house:
            return "House"
        case .building:
            return "Work"
        case .car:
            return "Car Insurance"
        case .fuelpump:
            return "Fuel"
        case .bus:
            return "Bus Pass"
        case .tram:
            return "Train Pass"
        case .airplane:
            return "Travel"
        case .sailboat:
            return "Boat"
        case .bed:
            return "Hotels"
        case .wifi:
            return "Internet"
        case .flame:
            return "Heating"
        case .snowflake:
            return "Air Conditioning"
        case .drop:
            return "Water"
        case .bolt:
            return "Electricity"
        case .hammer:
            return "Renovations"
        case .wrench:
            return "Repairs"
        case .lightbulb:
            return "Utilities"
        case .chair:
            return "Furnature"
        case .basket:
            return "Basket"
        case .wineglass:
            return "Alcohol"
        case .stethoscope:
            return "Doctor"
        case .pills:
            return "Medicine"
        case .pawprint:
            return "Pet Supplies"
        case .teddybear:
            return "Children"
        case .leaf:
            return "Garden"
        case .graduationcap:
            return "School"
        case .doc:
            return "Taxes"
        case .ticket:
            return "Entertainment"
        case .takeoutbag:
            return "Take Out"
        case .tshirt:
            return "Clothing"
        case .shippingbox:
            return "Online Shopping"
        case .iphone:
            return "Phone"
        case .icloud:
            return "Cloud Storage"
        case .music:
            return "Music"
        case .tv:
            return "TV"
        case .gamecontroller:
            return "Games"
        case .newspaper:
            return "News"
        case .figure:
            return "Personal"
        case .figurerun:
            return "Fitness"
        case .family:
            return "Family"
        case .app:
            return "App Subscriptions"
        case .star:
            return ""
        }
    }
    
    var color: Color {
        switch self {
        case .banknote:
            return .green
        case .bitcoin:
            return .orange
        case .creditcard:
            return .mint
        case .bag:
            return .mint
        case .gift:
            return .red
        case .bank:
            return .green
        case .stocks:
            return .blue
        case .house:
            return .brown
        case .building:
            return .cyan
        case .car:
            return .blue
        case .fuelpump:
            return .blue
        case .bus:
            return .blue
        case .tram:
            return .blue
        case .airplane:
            return .blue
        case .sailboat:
            return .blue
        case .bed:
            return .brown
        case .wifi:
            return .blue
        case .flame:
            return .orange
        case .snowflake:
            return .cyan
        case .drop:
            return .blue
        case .bolt:
            return .yellow
        case .hammer:
            return .orange
        case .wrench:
            return .gray
        case .lightbulb:
            return .yellow
        case .chair:
            return .brown
        case .basket:
            return .yellow
        case .wineglass:
            return .purple
        case .stethoscope:
            return .pink
        case .pills:
            return .pink
        case .pawprint:
            return .brown
        case .teddybear:
            return .brown
        case .leaf:
            return .green
        case .graduationcap:
            return .indigo
        case .doc:
            return .gray
        case .ticket:
            return .purple
        case .takeoutbag:
            return .orange
        case .tshirt:
            return .purple
        case .shippingbox:
            return .brown
        case .iphone:
            return .blue
        case .icloud:
            return .cyan
        case .music:
            return .pink
        case .tv:
            return .indigo
        case .gamecontroller:
            return .red
        case .newspaper:
            return .pink
        case .figure:
            return .blue
        case .figurerun:
            return .green
        case .family:
            return .blue
        case .app:
            return .blue
        case .star:
            return .gray
        }
    }
}
