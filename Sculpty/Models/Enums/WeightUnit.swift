//
//  WeightUnit.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/26/25.
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
