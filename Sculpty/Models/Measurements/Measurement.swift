//
//  Measurement.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import Foundation
import SwiftData

@Model
class Measurement: Identifiable {
    var id: UUID = UUID()
    
    var date: Date = Date()
    var unit: String = UnitsManager.weight
    var measurement: Double = 0
    var type: MeasurementType = MeasurementType.other
    
    init(
        date: Date = Date(),
        measurement: Double = 0,
        unit: String = UnitsManager.weight,
        type: MeasurementType = .other
    ) {
        self.date = date
        self.unit = unit
        self.measurement = measurement
        self.type = type
    }
    
    // swiftlint:disable force_unwrapping
    func getConvertedMeasurement() -> Double {
        // Weight
        if type == .weight {
            return WeightUnit(rawValue: unit)!
                .convert(
                    measurement,
                    to: WeightUnit(rawValue: UnitsManager.weight)!
                )
        }
        // Length
        else if MeasurementType.lengthTypes.contains(type) {
            return ShortLengthUnit(rawValue: unit)!
                .convert(
                    measurement,
                    to: ShortLengthUnit(rawValue: UnitsManager.shortLength)!
                )
        }
        // Percent/Other
        else {
            return measurement
        }
    }
    // swiftlint:enable force_unwrapping
    
    private func ftToFtIn(_ ft: Double) -> String {
        let inches = ft - (ft.truncatingRemainder(dividingBy: 12))
        return "\(Int(ft))\(inches.isZero ? "" : " \(Int(inches))")"
    }
}
