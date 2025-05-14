//
//  WorkoutSummaryPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/13/25.
//

import SwiftUI
import MijickPopups

struct WorkoutSummaryPopup: CenterPopup {
    private var log: WorkoutLog
    
    @AppStorage(UserKeys.includeWarmUp.rawValue) private var includeWarmUp: Bool = true
    @AppStorage(UserKeys.includeDropSet.rawValue) private var includeDropSet: Bool = true
    @AppStorage(UserKeys.includeCoolDown.rawValue) private var includeCoolDown: Bool = true
    
    init(log: WorkoutLog) {
        self.log = log
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack (alignment: .center, spacing: 8){
                Text(log.workout.name)
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                
                Text("Total Time: \(lengthToString(length: log.getLength()))")
                    .bodyText()
                    .textColor()
                
                Text("Total Reps: \(log.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown)) reps")
                    .bodyText()
                    .textColor()
                
                Text("Total Weight: \(log.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown).formatted())\(UnitsManager.weight)")
                    .bodyText()
                    .textColor()
                
                
                Spacer()
                    .frame(height: 5)
                
                
                let muscleGroups = log.getMuscleGroupBreakdown()
                Text("Muscle Groups Worked:")
                    .bodyText()
                    .textColor()
                
                ForEach(MuscleGroup.displayOrder, id: \.id) { group in
                    if group != .overall && muscleGroups.contains(group) {
                        HStack(alignment: .center, spacing: 4) {
                            Circle()
                                .fill(MuscleGroup.colorMap[group]!)
                                .frame(width: 8, height: 8)
                            
                            Text(group.rawValue.capitalized)
                                .bodyText()
                                .textColor()
                        }
                    }
                }
            }
            
            Button {
                Task {
                    await dismissLastPopup()
                }
            } label: {
                Text("OK")
                    .bodyText(size: 18, weight: .bold)
            }
            .textColor()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
    }
    
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig {
        config
            .backgroundColor(ColorManager.background)
            .popupHorizontalPadding(24)
    }
}
