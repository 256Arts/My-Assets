//
//  PieChart.swift
//  My Assets
//
//  Created by Jayden Irwin on 2021-10-20.
//  Copyright © 2021 Jayden Irwin. All rights reserved.
//

import SwiftUI

struct PieChart: View {
    
    struct Item {
        let value: Double
        let color: Color
    }
    
    @State var data: [Item]
    
    var body: some View {
        ZStack {
            ForEach(data.indices, id: \.self) { index in
                PieSlice(startAngle: trimLocations(index: index).start, endAngle: trimLocations(index: index).end)
                    .fill(data[index].color.gradient)
            }
        }
    }
    
    func trimLocations(index: Int) -> (start: Angle, end: Angle) {
        let totalValue = data.reduce(0) { $0 + $1.value }
        if index == -1 {
            return (.degrees(-90), .degrees(-90))
        } else {
            let start = trimLocations(index: index - 1).end
            return (start, start + .degrees((data[index].value / totalValue) * 360))
        }
    }
    
}

struct PieGraph_Previews: PreviewProvider {
    static var previews: some View {
        PieChart(data: [.init(value: 20, color: .red), .init(value: 100, color: .blue)])
    }
}
