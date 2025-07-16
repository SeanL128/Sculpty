//
//  SetLog.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/5/25.
//

import Foundation
import SwiftData

@Model
class SetLog: Identifiable {
    var id: UUID = UUID()
    var exerciseLog: ExerciseLog?
    @Relationship(deleteRule: .nullify, inverse: \ExerciseSet._setLogs) var set: ExerciseSet?
    var index: Int = 0
    
    var completed: Bool = false
    var skipped: Bool = false
    var start: Date = Date()
    var end: Date = Date(timeIntervalSince1970: 0)
    
    var unit: String = UnitsManager.weight
    
    // Weight-specific
    var reps: Int?
    var weight: Double?
    
    // Distance-specific
    var time: Double?
    var distance: Double?
    
    init(index: Int,
         set: ExerciseSet,
         unit: String) {
        self.index = index
        self.set = set
        self.unit = unit
        
        if set.exerciseType == .weight {
            reps = 0
            weight = 0
        } else if set.exerciseType == .distance {
            time = 0
            distance = 0
        }
    }
    
    init(from set: ExerciseSet) {
        index = set.index
        self.set = set
        unit = set.unit
        
        if set.exerciseType == .weight {
            reps = 0
            weight = 0
        } else if set.exerciseType == .distance {
            time = 0
            distance = 0
        }
    }
    
    func finish(reps: Int, weight: Double) {
        completed = true
        end = Date()
        
        self.reps = reps
        self.weight = weight * Double(reps)
    }
    
    func finish(time: Double, distance: Double) {
        completed = true
        end = Date()
        
        self.time = time
        self.distance = distance
    }
    
    func unfinish() {
        completed = false
        end = Date(timeIntervalSince1970: 0)
        
        if reps != nil && weight != nil {
            reps = 0
            weight = 0
        } else if time != nil && distance != nil {
            time = 0
            distance = 0
        }
    }
    
    func skip() {
        skipped = true
        completed = false
        end = Date()
        
        if reps != nil && weight != nil {
            reps = 0
            weight = 0
        } else if time != nil && distance != nil {
            time = 0
            distance = 0
        }
    }
    
    func unskip() {
        skipped = false
        end = Date(timeIntervalSince1970: 0)
        
        if reps != nil && weight != nil {
            reps = 0
            weight = 0
        } else if time != nil && distance != nil {
            time = 0
            distance = 0
        }
    }
    
    func getOneRM() -> Double {
        if set?.type == .main,
           let weight = weight,
           let reps = reps {
            return round(((weight / Double(reps) / Double(reps)) * (1.0 + (Double(reps) / 30.0))), 2)
        } else {
            return 0
        }
    }
}
