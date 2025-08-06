//
//  WorkoutLiveActivityAttributes.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/18/25.
//

import ActivityKit

struct WorkoutLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var workoutName: String
        var currentExerciseName: String
        var currentSetText: String
        var nextSetText: String
        var workoutProgress: Double
    }
    
    var workoutId: String
}
