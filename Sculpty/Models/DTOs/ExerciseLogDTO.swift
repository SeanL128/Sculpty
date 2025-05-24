//
//  ExerciseLogDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation

struct ExerciseLogDTO: Identifiable, Codable {
    var id: UUID
    var index: Int
    var exercise: WorkoutExerciseDTO
    var completed: Bool
    var start: Date
    var end: Date
    var setLogs: [SetLogDTO]
    
    init(from model: ExerciseLog) {
        self.id = model.id
        self.index = model.index
        self.exercise = WorkoutExerciseDTO(from: model.exercise)
        self.completed = model.completed
        self.start = model.start
        self.end = model.end
        self.setLogs = model.setLogs.map { SetLogDTO(from: $0) }
    }
    
    func toModel(exerciseMap: [UUID: Exercise]? = nil, setMap: [UUID: ExerciseSet]? = nil) -> ExerciseLog {
        let exerciseModel = exercise.toModel(exerciseMap: exerciseMap)
        let exerciseLog = ExerciseLog(index: index, exercise: exerciseModel)
        
        exerciseLog.id = id
        exerciseLog.completed = completed
        exerciseLog.start = start
        exerciseLog.end = end
        exerciseLog.setLogs = setLogs.map { $0.toModel(setMap: setMap) }
        
        return exerciseLog
    }
}
