//
//  WorkoutSummary.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI

struct WorkoutSummary: View {
    private var workoutLog: WorkoutLog
    private var workout: Workout
    
    init(workoutLog: WorkoutLog) {
        self.workoutLog = workoutLog
        self.workout = workoutLog.workout
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(workout.name)
                    .font(.headline)
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                
                Text("Total Time: \(lengthToString(length: workoutLog.getLength()))")
                    .padding(.bottom, 5)
                
                Text("Total Reps: \(workoutLog.getTotalReps()) reps")
                    .padding(.bottom, 5)
                
                Text("Total Weight: \(workoutLog.getTotalWeight().formatted())lbs")
                    .padding(.bottom, 5)
                
                let muscleGroups = workoutLog.getMuscleGroupBreakdown()
                Text("Muscle Groups Worked:")
                
                ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { group in
                    if group != .overall && muscleGroups.contains(group) {
                        Text(group.rawValue.capitalized)
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    WorkoutSummary(workoutLog: WorkoutLog(workout: Workout()))
}
