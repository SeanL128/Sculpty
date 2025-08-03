//
//  SetView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import SwiftUI

struct SetView: View {
    @EnvironmentObject private var settings: CloudSettings
    
    let set: ExerciseSet
    var setLog: SetLog?
    
    var body: some View {
        HStack(alignment: .center, spacing: .spacingXS) {
            ZStack(alignment: .center) {
                switch set.type {
                case .warmUp:
                    Image(systemName: "bolt.fill")
                        .bodyText()
                case .dropSet:
                    Image(systemName: "arrowtriangle.down.fill")
                        .bodyText()
                case .coolDown:
                    Image(systemName: "drop.fill")
                        .bodyText()
                default:
                    Text("")
                }
            }
            .frame(width: 20, height: 40)
            
            if set.exerciseType == .weight,
               let reps = set.reps,
               let weight = set.weight,
               let rir = set.rir {
                Text("\(reps)x\(String(format: "%0.2f", weight)) \(set.unit)\((settings.showRir && [.main, .dropSet].contains(set.type)) ? " (\(rir)\((rir) == "Failure" ? "" : " RIR"))" : "")") // swiftlint:disable:this line_length
                    .bodyText()
                    .strikethrough(setLog?.completed ?? false || setLog?.skipped ?? false)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: weight)
                    .animation(.easeInOut(duration: 0.3), value: reps)
                    .animation(.easeInOut(duration: 0.3), value: setLog?.completed)
                    .animation(.easeInOut(duration: 0.3), value: setLog?.skipped)
                
                Spacer()
                
                if settings.show1RM && set.type == .main && (setLog?.completed ?? false) {
                    Text("1RM: \(String(format: "%0.2f", weight * (1.0 + (Double(reps) / 30.0))))\(set.unit)")
                        .bodyText()
                        .secondaryColor()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: weight * (1.0 + (Double(reps) / 30.0)))
                }
            } else if set.exerciseType == .distance,
                      let distance = set.distance {
                Text("\(set.timeString) \(String(format: "%0.2f", distance))\(set.unit)")
                    .bodyText()
                    .strikethrough(setLog?.completed ?? false || setLog?.skipped ?? false)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: distance)
                    .animation(.easeInOut(duration: 0.3), value: setLog?.completed)
                    .animation(.easeInOut(duration: 0.3), value: setLog?.skipped)
                
                Spacer()
            }
        }
    }
}
