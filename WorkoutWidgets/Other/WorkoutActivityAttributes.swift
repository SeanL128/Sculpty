//
//  WorkoutActivityAttributes.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/18/25.
//

import Foundation
import ActivityKit

struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var workoutName: String
        var currentExerciseName: String
        var currentSetText: String
        var nextSetText: String
        var workoutProgress: Double
    }
    
    var workoutId: String
}
