//
//  TimeRange.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/9/25.
//

import Foundation

enum TimeRange: String, CaseIterable {
    case week = "Last 7 Days"
    case month = "Last 30 Days"
    case all = "All Time"
    case custom = "Custom Range"
}
