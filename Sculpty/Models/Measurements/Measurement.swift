//
//  Measurement.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import Foundation
import SwiftData

@Model
class Measurement: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var date: Date
    var unit: String
    var measurement: Double
    var type: MeasurementType
    
    init(date: Date = Date(), measurement: Double = 0, unit: String = UnitsManager.weight, type: MeasurementType = .other) {
        self.date = date
        self.unit = unit
        self.measurement = measurement
        self.type = type
    }
    
    func getMeasurementString() -> String {
        // Weight
        if type == .weight {
            return "\(WeightUnit.kg.convert(measurement, to: WeightUnit(rawValue: UnitsManager.weight)!).formatted())\(UnitsManager.weight)"
        }
        // Height
        else if type == .height {
            let unit = MediumLengthUnit(rawValue: UnitsManager.mediumLength)!
            let height = MediumLengthUnit.m.convert(measurement, to: unit)
            
            if unit.rawValue == "ft" {
                return "\(Int(height))ft\((height - (height.truncatingRemainder(dividingBy: 12))).isZero ? "" : " \(Int(height - (height.truncatingRemainder(dividingBy: 12))))in")"
            } else {
                return "\(height.formatted())m"
            }
        }
        // Length
        else if [.neck, .shoulders, .chest, .upperArmLeft, .upperArmRight, .forearmLeft, .forearmRight, .waist, .hips, .thighLeft, .thighRight, .calfLeft, .calfRight].contains(type) {
            return "\(ShortLengthUnit.cm.convert(measurement, to: ShortLengthUnit(rawValue: UnitsManager.shortLength)!).formatted())\(UnitsManager.shortLength)"
        }
        // Percent
        else if type == .bodyFat {
            return "\(measurement.formatted())%"
        }
        // Other
        else {
            return measurement.formatted()
        }
    }
    
    private func ftToFtIn(_ ft: Double) -> String {
        let inches = ft - (ft.truncatingRemainder(dividingBy: 12))
        return "\(Int(ft))\(inches.isZero ? "" : " \(Int(inches))")"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, unit, measurement, type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        unit = try container.decode(String.self, forKey: .unit)
        measurement = try container.decode(Double.self, forKey: .measurement)
        type = try container.decode(MeasurementType.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(unit, forKey: .unit)
        try container.encode(measurement, forKey: .measurement)
        try container.encode(type, forKey: .type)
    }
}
