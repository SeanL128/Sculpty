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
    
    var toKgFactor: Double {
        return self == .lbs ? 0.453592 : 1.0
    }
    
    var fromKgFactor: Double {
        return self == .lbs ? 2.20462 : 1.0
    }
    
    func convert(_ value: Double, to unit: WeightUnit) -> Double {
        if self == unit { return value }
        
        let kgValue = value * self.toKgFactor
        return (kgValue * unit.fromKgFactor * 100).rounded() / 100
    }
}

enum ShortLengthUnit: String, CaseIterable {
    case inch = "in"
    case cm = "cm"
    
    var toCmFactor: Double {
        return self == .inch ? 2.54 : 1.0
    }
    
    var fromCmFactor: Double {
        return self == .inch ? 0.393701 : 1.0
    }
    
    func convert(_ value: Double, to unit: ShortLengthUnit) -> Double {
        if self == unit { return value }
        
        let cmValue = value * self.toCmFactor
        return (cmValue * unit.fromCmFactor * 100).rounded() / 100
    }
}

enum MediumLengthUnit: String, CaseIterable {
    case ft = "ft"
    case m = "m"
    
    var toMFactor: Double {
        return self == .ft ? 0.3048 : 1.0
    }
    
    var fromMFactor: Double {
        return self == .ft ? 3.28084 : 1.0
    }
    
    func convert(_ value: Double, to unit: MediumLengthUnit) -> Double {
        if self == unit { return value }
        
        let mValue = value * self.toMFactor
        return (mValue * unit.fromMFactor * 100).rounded() / 100
    }
}

enum LongLengthUnit: String, CaseIterable {
    case mi = "mi"
    case km = "km"
    
    var toKmFactor: Double {
        return self == .mi ? 1.60934 : 1.0
    }
    
    var fromKmFactor: Double {
        return self == .mi ? 0.621371 : 1.0
    }
    
    func convert(_ value: Double, to unit: LongLengthUnit) -> Double {
        if self == unit { return value }
        
        let kmValue = value * self.toKmFactor
        return (kmValue * unit.fromKmFactor * 100).rounded() / 100
    }
}
