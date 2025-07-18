//
//  WorkoutSummaryPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/13/25.
//

import SwiftUI

struct WorkoutSummaryPopup: View {
    @EnvironmentObject private var settings: CloudSettings
    
    private let log: WorkoutLog
    private let muscleGroups: [MuscleGroup]
    
    private var time: String { lengthToString(length: log.getLength()) }
    // swiftlint:disable line_length
    private var reps: String { "\(log.getTotalReps(settings.includeWarmUp, settings.includeDropSet, settings.includeCoolDown))"}
    private var weight: String { log.getTotalWeight(settings.includeWarmUp, settings.includeDropSet, settings.includeCoolDown).formatted() }
    // swiftlint:enable line_length
    
    init(log: WorkoutLog) {
        self.log = log
        muscleGroups = log.getMuscleGroupBreakdown()
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(alignment: .center, spacing: 8) {
                Text(log.workout?.name ?? "")
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                Text("Total Time: \(time)")
                    .bodyText(size: 16)
                    .textColor()
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: time)
                
                Text("Total Reps: \(reps) reps")
                    .bodyText(size: 16)
                    .textColor()
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: reps)
                
                Text("Total Weight: \(weight)\(UnitsManager.weight)")
                    .bodyText(size: 16)
                    .textColor()
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: weight)
                
                Spacer()
                    .frame(height: 5)
                
                MuscleGroupDisplay(groups: muscleGroups)
            }
            
            Button {
                Popup.dismissLast()
            } label: {
                Text("OK")
                    .bodyText(size: 18, weight: .bold)
            }
            .textColor()
            .animatedButton()
        }
    }
}
