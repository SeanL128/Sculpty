//
//  LineChartData.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/3/25.
//

import SwiftUI

struct LineChartData: Identifiable {
    var id: String { name }
    
    let data: [(date: Date, value: Double)]
    let color: Color
    let name: String
}
