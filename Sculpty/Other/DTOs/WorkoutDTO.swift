//
//  WorkoutDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation

struct WorkoutDTO: Identifiable, Codable {
    var id: UUID
    var index: Int
    var name: String
    var exercises: [WorkoutExerciseDTO]
    var notes: String
    var lastStarted: Date?
    var hidden: Bool
    
    init(from model: Workout) {
        self.id = model.id
        self.index = model.index
        self.name = model.name
        self.exercises = model.exercises.map { WorkoutExerciseDTO(from: $0) }
        self.notes = model.notes
        self.lastStarted = model.lastStarted
        self.hidden = model.hidden
    }
    
    func toModel(exerciseMap: [UUID: Exercise]? = nil) -> Workout {
        let workout = Workout(
            index: index,
            name: name,
            exercises: exercises.map { $0.toModel(exerciseMap: exerciseMap) },
            notes: notes,
            lastStarted: lastStarted,
            hidden: hidden
        )
        workout.id = id
        return workout
    }
}
