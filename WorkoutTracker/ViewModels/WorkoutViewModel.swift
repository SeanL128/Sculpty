//
//  WorkoutViewModel.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/16/25.
//

import Foundation
import SwiftData

class WorkoutViewModel: ObservableObject {
    @Published var workout: Workout
    @Published var workoutName: String
    @Published var exercises: [WorkoutExercise]
    @Published var notes: String = ""
    
    init(workout: Workout = Workout()) {
        self.workout = workout
        self.workoutName = workout.name
        self.exercises = workout.exercises
        self.notes = workout.notes
    }
    
    func addExercise() {
        let nextIndex = exercises.map { $0.index }.max() ?? -1
        exercises.append(WorkoutExercise(index: nextIndex + 1))
    }
    
    func removeExercise(at index: Int) {
        guard index < exercises.count else { return }
        exercises.remove(at: index)
    }
}
