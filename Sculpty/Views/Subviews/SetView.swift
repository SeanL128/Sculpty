//
//  SetView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import SwiftUI

struct SetView: View {
    var set: ExerciseSet
    var setLog: SetLog?
    
    @AppStorage(UserKeys.show1RM.rawValue) private var show1RM: Bool = false
    @AppStorage(UserKeys.showRir.rawValue) private var showRir: Bool = false
    
    var body: some View {
        HStack {
            ZStack {
                switch (set.type) {
                case (.warmUp):
                    Image(systemName: "bolt.fill")
                case (.dropSet):
                    Image(systemName: "arrowtriangle.down.fill")
                case (.coolDown):
                    Image(systemName: "drop.fill")
                default:
                    Text("")
                }
            }
            .frame(width: 20, height: 40)
            
            if set.exerciseType == .weight,
               let reps = set.reps,
               let weight = set.weight,
               let measurement = set.measurement,
               let rir = set.rir {
                Text("\(reps) \(measurement) \(String(format: "%0.2f", weight)) \(set.unit) \((showRir && [.main, .dropSet].contains(set.type)) ? "(\(rir)\((rir) == "Failure" ? "" : " RIR"))" : "")")
                    .strikethrough(setLog?.completed ?? false || setLog?.skipped ?? false)
                
                Spacer()
                
                if show1RM && set.type == .main && (setLog?.completed ?? false) {
                    Text("1RM: \(String(format: "%0.2f", weight * (1.0 + (Double(reps) / 30.0)))) \(set.unit)")
                        .foregroundStyle(ColorManager.secondary)
                }
            } else if set.exerciseType == .distance,
                      let distance = set.distance {
                Text("\(set.timeString) \(String(format: "%0.2f", distance)) \(set.unit)")
                    .strikethrough(setLog?.completed ?? false || setLog?.skipped ?? false)
                
                Spacer()
            }
        }
        .frame(height: 37)
    }
}
