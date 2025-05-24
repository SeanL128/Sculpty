//
//  WorkoutExerciseDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation

struct WorkoutExerciseDTO: Identifiable, Codable {
    var id: UUID
    var index: Int
    var exerciseId: UUID?
    var sets: [ExerciseSetDTO]
    var restTime: TimeInterval
    var specNotes: String
    var tempo: String
    
    init(from model: WorkoutExercise) {
        self.id = model.id
        self.index = model.index
        self.exerciseId = model.exercise?.id
        self.sets = model.sets.map { ExerciseSetDTO(from: $0) }
        self.restTime = model.restTime
        self.specNotes = model.specNotes
        self.tempo = model.tempo
    }
    
    func toModel(exerciseMap: [UUID: Exercise]? = nil) -> WorkoutExercise {
        let workoutExercise = WorkoutExercise(
            index: index,
            exercise: exerciseId.flatMap { exerciseMap?[$0] },
            sets: sets.map { $0.toModel() },
            restTime: restTime,
            specNotes: specNotes.isEmpty ? "" : specNotes,
            tempo: tempo.isEmpty ? "0000" : tempo
        )
        workoutExercise.id = id
        
        // Ensure all required fields have values to avoid validation errors
        if workoutExercise.index == 0 {
            workoutExercise.index = 1
        }
        
        if workoutExercise.restTime == 0 {
            workoutExercise.restTime = 180 // Default rest time in seconds
        }
        
        return workoutExercise
    }
}
