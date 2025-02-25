//
//  WorkoutSummary.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI

struct WorkoutSummary: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(UserKeys.includeWarmUp.rawValue) private var includeWarmUp: Bool = true
    @AppStorage(UserKeys.includeDropSet.rawValue) private var includeDropSet: Bool = true
    @AppStorage(UserKeys.includeCoolDown.rawValue) private var includeCoolDown: Bool = true
    
    private var workoutLog: WorkoutLog?
    private var workout: Workout?
    
    init(workoutLog: WorkoutLog?) {
        self.workoutLog = workoutLog
        self.workout = workoutLog?.workout
        
        finishInit()
    }
    
    private func finishInit() {
        if workoutLog == nil || workout == nil {
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    Text(workout!.name)
                        .font(.headline)
                        .padding(.vertical, 10)
                    
                    Text("Total Time: \(lengthToString(length: workoutLog!.getLength()))")
                        .padding(.bottom, 5)
                    
                    Text("Total Reps: \(workoutLog!.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown)) reps")
                        .padding(.bottom, 5)
                    
                    Text("Total Weight: \(workoutLog!.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown).formatted())\(UnitsManager.weight)")
                        .padding(.bottom, 5)
                    
                    let muscleGroups = workoutLog!.getMuscleGroupBreakdown()
                    Text("Muscle Groups Worked:")
                    
                    ForEach(MuscleGroup.displayOrder, id: \.id) { group in
                        if group != .overall && muscleGroups.contains(group) {
                            Text(group.rawValue.capitalized)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    WorkoutSummary(workoutLog: WorkoutLog(workout: Workout()))
}
