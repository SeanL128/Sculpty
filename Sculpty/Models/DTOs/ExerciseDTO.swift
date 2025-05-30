//
//  ExerciseDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation

struct ExerciseDTO: Identifiable, Codable {
    var id: UUID
    var name: String
    var notes: String
    var muscleGroup: MuscleGroup?
    var type: ExerciseType
    var hidden: Bool
    
    init(from model: Exercise) {
        self.id = model.id
        self.name = model.name
        self.notes = model.notes
        self.muscleGroup = model.muscleGroup
        self.type = model.type
        self.hidden = model.hidden
    }
    
    func toModel() -> Exercise {
        let exercise = Exercise(name: name, notes: notes, muscleGroup: muscleGroup ?? .other, type: type, hidden: hidden)
        exercise.id = id
        return exercise
    }
}
