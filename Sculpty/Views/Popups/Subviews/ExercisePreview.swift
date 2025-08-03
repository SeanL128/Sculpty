//
//  ExercisePreview.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/17/25.
//

import SwiftUI

struct ExercisePreview: View {
    @EnvironmentObject private var settings: CloudSettings
    
    let exercise: WorkoutExercise
    let index: Int
    
    @State private var open: Bool = false
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                open.toggle()
            }
        } label: {
            HStack(alignment: .center, spacing: .spacingXS) {
                Text(exercise.exercise?.name ?? "Exercise \(index + 1)")
                    .bodyText(weight: .regular)
                    .multilineTextAlignment(.leading)
                
                Image(systemName: "chevron.down")
                    .bodyImage()
                    .rotationEffect(.degrees(open ? -180 : 0))
            }
        }
        .textColor()
        .animatedButton()
        
        if open {
            VStack(alignment: .leading, spacing: .spacingS) {
                ForEach(exercise.sets.sorted { $0.index < $1.index }, id: \.id) { set in
                    HStack(alignment: .center, spacing: .spacingXS) {
                        ZStack(alignment: .center) {
                            switch set.type {
                            case .warmUp:
                                Image(systemName: "bolt.fill")
                                    .secondaryText()
                            case .dropSet:
                                Image(systemName: "arrowtriangle.down.fill")
                                    .secondaryText()
                            case .coolDown:
                                Image(systemName: "drop.fill")
                                    .secondaryText()
                            default:
                                Text("")
                            }
                        }
                        .frame(width: 15, height: 35)
                        
                        HStack(alignment: .center) {
                            if set.exerciseType == .weight,
                               let reps = set.reps,
                               let weight = set.weight,
                               let rir = set.rir {
                                Text("\(reps) x \(String(format: "%0.2f", weight)) \(set.unit)\((settings.showRir && [.main, .dropSet].contains(set.type)) ? " (\(rir)\((rir) == "Failure" ? "" : " RIR"))" : "")") // swiftlint:disable:this line_length
                                    .secondaryText()
                                    .textColor()
                                    .monospacedDigit()
                                    .contentTransition(.numericText())
                                    .animation(.easeInOut(duration: 0.3), value: weight)
                                    .animation(.easeInOut(duration: 0.3), value: reps)
                            } else if set.exerciseType == .distance,
                                      let distance = set.distance {
                                Text("\(set.timeString) \(String(format: "%0.2f", distance)) \(set.unit)")
                                    .secondaryText()
                                    .textColor()
                                    .monospacedDigit()
                                    .contentTransition(.numericText())
                                    .animation(.easeInOut(duration: 0.3), value: distance)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
}
