//
//  BarChartData.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/3/25.
//

import Foundation

struct BarChartData: Identifiable {
    var id: Date { date }
    
    let date: Date
    let value: Double
}
