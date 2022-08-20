//
//  PieSlice.swift
//  My Assets
//
//  Created by Jayden Irwin on 2021-10-20.
//  Copyright © 2021 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct PieSlice: Shape {
    
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let radius = min(rect.size.width, rect.size.height) / 2
            let center = CGPoint(x: rect.midX, y: rect.midY)
            
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x + cos(CGFloat(startAngle.radians)), y: center.y + sin(CGFloat(startAngle.radians))))
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false)
            path.closeSubpath()
        }
    }
    
}
