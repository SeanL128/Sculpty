//
//  MeasurementDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation

struct MeasurementDTO: Identifiable, Codable {
    var id: UUID
    var date: Date
    var unit: String
    var measurement: Double
    var type: MeasurementType
    
    init(from model: Measurement) {
        self.id = model.id
        self.date = model.date
        self.unit = model.unit
        self.measurement = model.measurement
        self.type = model.type
    }
    
    func toModel() -> Measurement {
        let measurement = Measurement(date: date, measurement: self.measurement, unit: unit, type: type)
        measurement.id = id
        return measurement
    }
}
