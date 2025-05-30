//
//  LongLengthUnit.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/26/25.
//

import Foundation

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
