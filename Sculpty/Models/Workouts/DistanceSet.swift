//
//  DistanceSet.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/24/25.
//

import Foundation
import SwiftData

@Model
class DistanceSet: BaseSet {
    var time: Double
    var distance: Double
    var unit: String
    var type: ExerciseSetType
    
    init(index: Int = 0,
         time: Double = UserDefaults.standard.object(forKey: UserKeys.defaultTime.rawValue) as? Double ?? 300,
         distance: Double = UserDefaults.standard.object(forKey: UserKeys.defaultDistance.rawValue) as? Double ?? 1,
         unit: String = UserDefaults.standard.object(forKey: UserKeys.defaultDistanceUnits.rawValue) as? String ?? UnitsManager.longLength,
         type: ExerciseSetType = ExerciseSetType(rawValue: UserDefaults.standard.object(forKey: UserKeys.defaultType.rawValue) as? String ?? "Main") ?? .main) {
        self.time = time
        self.distance = distance
        self.unit = unit
        self.type = type
        
        super.init(index: index)
    }
    
    func copy() -> DistanceSet {
        return DistanceSet(index: index, time: time, distance: distance, unit: unit, type: type)
    }
    
    func distance(in unit: LongLengthUnit) -> Double {
        return LongLengthUnit(rawValue: self.unit)!.convert(distance, to: unit)
    }
    
    func timeToString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    enum CodingKeys: String, CodingKey {
        case time, distance, unit, type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        time = try container.decode(Double.self, forKey: .time)
        distance = try container.decode(Double.self, forKey: .distance)
        unit = try container.decode(String.self, forKey: .unit)
        type = try container.decode(ExerciseSetType.self, forKey: .type)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time, forKey: .time)
        try container.encode(distance, forKey: .distance)
        try container.encode(unit, forKey: .unit)
        try container.encode(type, forKey: .type)
        try super.encode(to: encoder)
    }
}
