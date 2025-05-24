//
//  WorkoutLogDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation

struct WorkoutLogDTO: Identifiable, Codable {
    var id: UUID
    var workout: WorkoutDTO
    var started: Bool
    var completed: Bool
    var start: Date
    var end: Date
    var exerciseLogs: [ExerciseLogDTO]
    
    init(from model: WorkoutLog) {
        self.id = model.id
        self.workout = WorkoutDTO(from: model.workout)
        self.started = model.started
        self.completed = model.completed
        self.start = model.start
        self.end = model.end
        self.exerciseLogs = model.exerciseLogs.map { ExerciseLogDTO(from: $0) }
    }
    
    func toModel(exerciseMap: [UUID: Exercise]? = nil, setMap: [UUID: ExerciseSet]? = nil) -> WorkoutLog {
        let workoutModel = workout.toModel(exerciseMap: exerciseMap)
        let exerciseLogModels = exerciseLogs.map { $0.toModel(exerciseMap: exerciseMap, setMap: setMap) }
        
        let workoutLog = WorkoutLog(
            workout: workoutModel,
            started: started,
            completed: completed,
            start: start,
            end: end,
            exerciseLogs: exerciseLogModels
        )
        
        workoutLog.id = id
        return workoutLog
    }
}
