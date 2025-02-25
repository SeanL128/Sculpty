//
//  UnitConverter.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import Foundation

enum WeightUnit: String, CaseIterable {
    case lbs = "lbs"
    case kg = "kg"
    
    var conversionFactor: Double {
        return self == .lbs ? 2.20462 : 0.453592
    }
    
    func convert(_ value: Double, to unit: WeightUnit) -> Double {
        if self == unit { return value }
        return (value * conversionFactor * 100).rounded() / 100
    }
}

enum ShortLengthUnit: String, CaseIterable {
    case inch = "in"
    case cm = "cm"
    
    var conversionFactor: Double {
        return self == .inch ? 2.54 : 0.393701
    }
    
    func convert(_ value: Double, to unit: ShortLengthUnit) -> Double {
        if self == unit { return value }
        return (value * conversionFactor * 100).rounded() / 100
    }
}

enum MediumLengthUnit: String, CaseIterable {
    case ft = "ft"
    case m = "m"
    
    var conversionFactor: Double {
        return self == .ft ? 0.3048 : 3.28084
    }
    
    func convert(_ value: Double, to unit: MediumLengthUnit) -> Double {
        if self == unit { return value }
        return (value * conversionFactor * 100).rounded() / 100
    }
}

enum LongLengthUnit: String, CaseIterable {
    case mi = "mi"
    case km = "km"
    
    var conversionFactor: Double {
        return self == .mi ? 1.60934 : 0.621371
    }
    
    func convert(_ value: Double, to unit: LongLengthUnit) -> Double {
        if self == unit { return value }
        return (value * conversionFactor * 100).rounded() / 100
    }
}
