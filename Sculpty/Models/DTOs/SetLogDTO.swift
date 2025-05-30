//
//  SetLogDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation

struct SetLogDTO: Identifiable, Codable {
    var id: UUID
    var setId: UUID?
    var index: Int
    var completed: Bool
    var skipped: Bool
    var start: Date
    var end: Date
    var unit: String
    
    // Weight-specific
    var reps: Int?
    var weight: Double?
    
    // Distance-specific
    var time: Double?
    var distance: Double?
    
    init(from model: SetLog) {
        self.id = model.id
        self.setId = model.set?.id
        self.index = model.index
        self.completed = model.completed
        self.skipped = model.skipped
        self.start = model.start
        self.end = model.end
        self.unit = model.unit
        self.reps = model.reps
        self.weight = model.weight
        self.time = model.time
        self.distance = model.distance
    }
    
    func toModel(setMap: [UUID: ExerciseSet]? = nil) -> SetLog {
        let setLog: SetLog
        
        if let setId = setId, let set = setMap?[setId] {
            if set.exerciseType == .weight {
                setLog = SetLog(index: index, set: set, unit: unit)
            } else {
                setLog = SetLog(index: index, set: set, unit: unit)
            }
        } else {
            setLog = SetLog(index: index, set: ExerciseSet(), unit: unit.isEmpty ? UnitsManager.weight : unit)
        }
        
        setLog.id = id
        setLog.completed = completed
        setLog.skipped = skipped
        setLog.start = start
        setLog.end = end
        setLog.reps = reps ?? 0
        setLog.weight = weight ?? 0
        setLog.time = time ?? 0
        setLog.distance = distance ?? 0
        
        return setLog
    }
}
