//
//  WorkoutSummaryPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/13/25.
//

import SwiftUI

struct WorkoutSummaryPopup: View {
    @EnvironmentObject private var settings: CloudSettings
    
    private var log: WorkoutLog
    
    init(log: WorkoutLog) {
        self.log = log
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack (alignment: .center, spacing: 8){
                Text(log.workout?.name ?? "")
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                
                Text("Total Time: \(lengthToString(length: log.getLength()))")
                    .bodyText(size: 16)
                    .textColor()
                
                Text("Total Reps: \(log.getTotalReps(settings.includeWarmUp, settings.includeDropSet, settings.includeCoolDown)) reps")
                    .bodyText(size: 16)
                    .textColor()
                
                Text("Total Weight: \(log.getTotalWeight(settings.includeWarmUp, settings.includeDropSet, settings.includeCoolDown).formatted())\(UnitsManager.weight)")
                    .bodyText(size: 16)
                    .textColor()
                
                
                Spacer()
                    .frame(height: 5)
                
                
                let muscleGroups = log.getMuscleGroupBreakdown()
                Text("Muscle Groups Worked:")
                    .bodyText(size: 16)
                    .textColor()
                
                ForEach(MuscleGroup.displayOrder, id: \.id) { group in
                    if group != .overall && muscleGroups.contains(group) {
                        HStack(alignment: .center, spacing: 4) {
                            Circle()
                                .fill(MuscleGroup.colorMap[group]!)
                                .frame(width: 8, height: 8)
                            
                            Text(group.rawValue)
                                .bodyText(size: 16)
                                .textColor()
                        }
                    }
                }
            }
            
            Button {
                Popup.dismissLast()
            } label: {
                Text("OK")
                    .bodyText(size: 18, weight: .bold)
            }
            .textColor()
        }
    }
}
