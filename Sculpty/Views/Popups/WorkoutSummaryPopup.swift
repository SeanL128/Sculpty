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
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingM) {
                Text(log.workout?.name ?? "")
                    .subheadingText()
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .center, spacing: .spacingXS) {
                    Text("Total Time: \(time)")
                        .bodyText()
                        .textColor()
                        .monospacedDigit()
                    
                    Text("Total Reps: \(reps) reps")
                        .bodyText()
                        .textColor()
                        .monospacedDigit()
                    
                    Text("Total Weight: \(weight)\(UnitsManager.weight)")
                        .bodyText()
                        .textColor()
                        .monospacedDigit()
                }
                
                if !muscleGroups.isEmpty {
                    MuscleGroupDisplay(groups: muscleGroups, alignment: .center)
                }
            }
            
            VStack(alignment: .center, spacing: .spacingM) {
                Spacer()
                    .frame(height: 0)
                
                Button {
                    Popup.dismissLast()
                } label: {
                    Text("OK")
                        .bodyText()
                        .padding(.vertical, 12)
                        .padding(.horizontal, .spacingL)
                }
                .textColor()
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .animatedButton(feedback: .selection)
            }
        }
    }
}
