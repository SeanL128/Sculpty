//
//  ShortLengthUnit.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/26/25.
//

import Foundation

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
