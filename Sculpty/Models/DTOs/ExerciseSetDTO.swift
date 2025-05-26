//
//  ExerciseSetDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation

struct ExerciseSetDTO: Identifiable, Codable {
    var id: UUID
    var index: Int
    
    var unit: String
    var type: ExerciseSetType
    var exerciseType: ExerciseType
    
    // Weight-specific
    var reps: Int?
    var weight: Double?
    var rir: String?
    
    // Distance-specific
    var time: Double?
    var distance: Double?
    
    init(from model: ExerciseSet) {
        self.id = model.id
        self.index = model.index
        self.unit = model.unit
        self.type = model.type
        self.exerciseType = model.exerciseType
        self.reps = model.reps
        self.weight = model.weight
        self.rir = model.rir
        self.time = model.time
        self.distance = model.distance
    }
    
    func toModel() -> ExerciseSet {
        let set: ExerciseSet
        
        if exerciseType == .weight {
            set = ExerciseSet(
                index: index,
                reps: reps ?? 12,
                weight: weight ?? 40,
                unit: unit.isEmpty ? UnitsManager.weight : unit,
                type: type,
                rir: rir ?? "0"
            )
        } else {
            set = ExerciseSet(
                index: index,
                time: time ?? 300,
                distance: distance ?? 1,
                unit: unit.isEmpty ? UnitsManager.longLength : unit,
                type: type
            )
        }
        
        set.id = id
        set.exerciseType = exerciseType
        
        return set
    }
}
