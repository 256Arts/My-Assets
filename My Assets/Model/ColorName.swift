//
//  ColorName.swift
//  My Assets
//
//  Created by 256 Arts Developer on 2024-08-10.
//  Copyright © 2024 256 Arts Developer. All rights reserved.
//

import SwiftUI

enum ColorName: String, Codable, CaseIterable, Identifiable {
    case white, gray, black, red, green, blue, yellow, purple, orange
    
    var id: Self { self }
    
    var color: Color {
        switch self {
        case .white: .white
        case .gray: .gray
        case .black: .black
        case .red: .red
        case .green: .green
        case .blue: .blue
        case .yellow: .yellow
        case .purple: .purple
        case .orange: .orange
        }
    }
}
