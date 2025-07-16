//
//  UnitsManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import Foundation

final class UnitsManager {
    static var selection: String { CloudSettings.shared.units }
    
    static var weight: String {
        switch selection {
        case "Metric":
            return "kg"
        default:
            return "lbs"
        }
    }
    
    static var shortLength: String {
        switch selection {
        case "Metric":
            return "cm"
        default:
            return "in"
        }
    }
    
    static var mediumLength: String {
        switch selection {
        case "Metric":
            return "m"
        default:
            return "ft"
        }
    }
    
    static var longLength: String {
        switch selection {
        case "Metric":
            return "km"
        default:
            return "mi"
        }
    }
}
