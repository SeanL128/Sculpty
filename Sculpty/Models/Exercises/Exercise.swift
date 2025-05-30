//
//  Exercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import Foundation
import SwiftData

@Model
class Exercise: Identifiable {
    var id = UUID()
    
    var name: String = ""
    var notes: String = ""
    var muscleGroup: MuscleGroup?
    var type: ExerciseType = ExerciseType.weight
    var hidden: Bool = false
    
    var _workoutExercises: [WorkoutExercise]?
    var workoutExercises: [WorkoutExercise] {
        get { _workoutExercises ?? [] }
        set { _workoutExercises = newValue.isEmpty ? nil : newValue }
    }
    
    init(name: String = "", notes: String = "", muscleGroup: MuscleGroup = MuscleGroup.other, type: ExerciseType = .weight, hidden: Bool = false) {
        self.name = name
        self.notes = notes
        self.muscleGroup = muscleGroup
        self.type = type
        self.hidden = hidden
    }
    
    func hide() {
        hidden = true
    }
}
