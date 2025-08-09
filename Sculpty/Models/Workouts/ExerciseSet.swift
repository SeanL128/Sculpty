//
//  ExerciseSet.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/31/25.
//

import Foundation
import SwiftData

@Model
class ExerciseSet: Identifiable {
    var id = UUID()
    var workoutExercise: WorkoutExercise?
    var index: Int = 0
    
    var unit: String = UnitsManager.weight
    var type: ExerciseSetType = ExerciseSetType.main
    var exerciseType: ExerciseType = ExerciseType.weight
    
    var _setLogs: [SetLog]?
    var setLogs: [SetLog] {
        get { _setLogs ?? [] }
        set { _setLogs = newValue.isEmpty ? nil : newValue }
    }
    
    // Weight-specific
    var reps: Int?
    var weight: Double?
    var rir: String?
    
    // Distance-specific
    var time: Double?
    var distance: Double?
    var timeString: String {
        if let time = time {
            let totalSeconds = Int(time)
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60

            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        }
        
        return ""
    }
    
    init(index: Int = 0,
         reps: Int = 12,
         weight: Double = 40,
         unit: String = UnitsManager.weight,
         type: ExerciseSetType = .main,
         rir: String = "0") {
        self.index = index
        self.unit = unit
        self.type = type
        exerciseType = .weight
        
        self.reps = reps
        self.weight = weight
        self.rir = rir
    }
    
    init(index: Int = 0,
         time: Double = 300,
         distance: Double = 1,
         unit: String = UnitsManager.longLength,
         type: ExerciseSetType = .main) {
        self.index = index
        self.unit = unit
        self.type = type
        exerciseType = .distance
        
        self.time = time
        self.distance = distance
    }
    
    init(index: Int = 0, type: ExerciseType) {
        self.index = index
        unit = ""
        self.type = .main
        exerciseType = type
        
        if type == .weight {
            unit = UnitsManager.weight
            
            reps = 12
            weight = 40
            rir = "0"
        } else if type == .distance {
            unit = UnitsManager.longLength
            
            time = 300
            distance = 1
        }
    }
    
    func copy() -> ExerciseSet {
        return ExerciseSet(from: self)
    }
    
    private init(from set: ExerciseSet) {
        index = set.index
        unit = set.unit
        type = set.type
        exerciseType = set.exerciseType
        
        if set.exerciseType == .weight,
           let reps = set.reps,
           let weight = set.weight,
           let rir = set.rir {
            self.reps = reps
            self.weight = weight
            self.rir = rir
        }
        
        if set.exerciseType == .distance,
           let time = set.time,
           let distance = set.distance {
            self.time = time
            self.distance = distance
        }
    }
    
    func weight(in unit: WeightUnit) -> Double {
        if let weight = self.weight,
           let unit = WeightUnit(rawValue: self.unit) {
            return unit.convert(weight, to: unit)
        }
        
        return 0
    }
    
    func distance(in unit: LongLengthUnit) -> Double {
        if let distance = self.distance,
           let unit = LongLengthUnit(rawValue: self.unit) {
            return unit.convert(distance, to: unit)
        }
        
        return 0
    }
}
