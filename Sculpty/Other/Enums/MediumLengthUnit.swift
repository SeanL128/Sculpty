//
//  MediumLengthUnit.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/26/25.
//

import Foundation

enum MediumLengthUnit: String, CaseIterable {
    case ft
    case m
    
    var toMFactor: Double {
        return self == .ft ? 0.3048 : 1.0
    }
    
    var fromMFactor: Double {
        return self == .ft ? 3.28084 : 1.0
    }
    
    func convert(_ value: Double, to unit: MediumLengthUnit) -> Double {
        if self == unit { return value }
        
        let mValue = value * self.toMFactor
        return round(mValue * unit.fromMFactor, 2)
    }
}
