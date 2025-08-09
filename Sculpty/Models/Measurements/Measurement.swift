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
    
    func getConvertedMeasurement() -> Double {
        if type == .weight,
           let from = WeightUnit(rawValue: unit),
           let to = WeightUnit(rawValue: UnitsManager.weight) {
            return from.convert(measurement, to: to)
        } else if MeasurementType.lengthTypes.contains(type),
                  let from = ShortLengthUnit(rawValue: unit),
                  let to = ShortLengthUnit(rawValue: UnitsManager.shortLength) {
            return from.convert(measurement, to: to)
        } else {
            return measurement
        }
    }
    
    private func ftToFtIn(_ ft: Double) -> String {
        let inches = ft - (ft.truncatingRemainder(dividingBy: 12))
        
        return "\(Int(ft))\(inches == 0 ? "" : " \(Int(inches))")"
    }
}
