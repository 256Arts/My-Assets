//
//  Symbol.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2021-10-27.
//  Copyright © 2021 256 Arts Developer. All rights reserved.
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
    case house, building, storefront, car, fuelpump, bus, tram, airplane, sailboat
    case bed = "bed.double"
    
    // Household
    case wifi, flame, snowflake, drop, bolt, hammer, wrench, lightbulb
    case chair = "chair.lounge"
    case basket
    
    // Other
    case skateboard, skis, snowboard, surfboard
    case gymbag = "gym.bag"
    case wineglass
    case pills
    case stethoscope
    case pawprint, teddybear, leaf, graduationcap
    case doc = "doc.text"
    case ticket
    case takeoutbag = "takeoutbag.and.cup.and.straw"
    case tshirt, shoe, shippingbox, iphone, macbook
    
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
            "Cash"
        case .bitcoin:
            "Bitcoin"
        case .creditcard:
            "Credit Card"
        case .bag:
            "Shopping"
        case .gift:
            "Gifts"
        case .bank:
            "Bank Account"
        case .stocks:
            "Stocks"
        case .house:
            "House"
        case .building:
            "Work"
        case .storefront:
            "Shopping"
        case .car:
            "Car Insurance"
        case .fuelpump:
            "Fuel"
        case .bus:
            "Bus Pass"
        case .tram:
            "Train Pass"
        case .airplane:
            "Travel"
        case .sailboat:
            "Boat"
        case .bed:
            "Hotels"
        case .wifi:
            "Internet"
        case .flame:
            "Heating"
        case .snowflake:
            "Air Conditioning"
        case .drop:
            "Water"
        case .bolt:
            "Electricity"
        case .hammer:
            "Renovations"
        case .wrench:
            "Repairs"
        case .lightbulb:
            "Utilities"
        case .chair:
            "Furnature"
        case .basket:
            "Basket"
        case .skateboard:
            "Skateboard"
        case .skis:
            "Ski"
        case .snowboard:
            "Snowboard"
        case .surfboard:
            "Surfboard"
        case .gymbag:
            "Gym"
        case .wineglass:
            "Alcohol"
        case .stethoscope:
            "Doctor"
        case .pills:
            "Medicine"
        case .pawprint:
            "Pet Supplies"
        case .teddybear:
            "Children"
        case .leaf:
            "Garden"
        case .graduationcap:
            "School"
        case .doc:
            "Taxes"
        case .ticket:
            "Entertainment"
        case .takeoutbag:
            "Take Out"
        case .tshirt:
            "Clothing"
        case .shoe:
            "Shoes"
        case .shippingbox:
            "Online Shopping"
        case .iphone:
            "Phone"
        case .macbook:
            "Computer"
        case .icloud:
            "Cloud Storage"
        case .music:
            "Music"
        case .tv:
            "TV"
        case .gamecontroller:
            "Games"
        case .newspaper:
            "News"
        case .figure:
            "Personal"
        case .figurerun:
            "Fitness"
        case .family:
            "Family"
        case .app:
            "App Subscriptions"
        case .star:
            ""
        }
    }
    
    var color: Color {
        switch self {
        case .banknote:
            .green
        case .bitcoin:
            .orange
        case .creditcard:
            .mint
        case .bag:
            .mint
        case .gift:
            .red
        case .bank:
            .green
        case .stocks:
            .blue
        case .house:
            .brown
        case .building:
            .cyan
        case .storefront:
            .red
        case .car:
            .blue
        case .fuelpump:
            .blue
        case .bus:
            .blue
        case .tram:
            .blue
        case .airplane:
            .blue
        case .sailboat:
            .blue
        case .bed:
            .brown
        case .wifi:
            .blue
        case .flame:
            .orange
        case .snowflake:
            .cyan
        case .drop:
            .blue
        case .bolt:
            .yellow
        case .hammer:
            .orange
        case .wrench:
            .gray
        case .lightbulb:
            .yellow
        case .chair:
            .brown
        case .basket:
            .yellow
        case .skateboard:
            .mint
        case .skis:
            .blue
        case .snowboard:
            .blue
        case .surfboard:
            .blue
        case .gymbag:
            .mint
        case .wineglass:
            .purple
        case .stethoscope:
            .pink
        case .pills:
            .pink
        case .pawprint:
            .brown
        case .teddybear:
            .brown
        case .leaf:
            .green
        case .graduationcap:
            .indigo
        case .doc:
            .gray
        case .ticket:
            .purple
        case .takeoutbag:
            .orange
        case .tshirt:
            .purple
        case .shoe:
            .purple
        case .shippingbox:
            .brown
        case .iphone:
            .blue
        case .macbook:
            .blue
        case .icloud:
            .cyan
        case .music:
            .pink
        case .tv:
            .indigo
        case .gamecontroller:
            .red
        case .newspaper:
            .pink
        case .figure:
            .blue
        case .figurerun:
            .green
        case .family:
            .blue
        case .app:
            .blue
        case .star:
            .gray
        }
    }
}
