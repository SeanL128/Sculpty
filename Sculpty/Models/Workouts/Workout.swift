//
//  Workout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Model
class Workout: Identifiable {
    var id = UUID()
    
    var index: Int = -1
    var name: String = ""
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout) private var _exercises: [WorkoutExercise]?
    var exercises: [WorkoutExercise] {
        get { _exercises ?? [] }
        set { _exercises = newValue.isEmpty ? nil : newValue }
    }
    var notes: String = ""
    var lastStarted: Date?
    var hidden: Bool = false
    
    var _workoutLogs: [WorkoutLog]?
    var workoutLogs: [WorkoutLog] {
        get { _workoutLogs ?? [] }
        set { _workoutLogs = newValue.isEmpty ? nil : newValue }
    }
    
    init(
        index: Int = -1,
        name: String = "",
        exercises: [WorkoutExercise] = [],
        notes: String = "",
        lastStarted: Date? = nil,
        hidden: Bool = false
    ) {
        self.index = index
        self.name = name
        self.exercises = exercises
        self.notes = notes
        self.lastStarted = lastStarted
        self.hidden = hidden
    }
    
    func started(date: Date = Date()) {
        lastStarted = date
    }
    
    func hide() {
        hidden = true
    }
}
