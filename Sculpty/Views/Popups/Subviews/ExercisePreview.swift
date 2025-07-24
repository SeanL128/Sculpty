//
//  ExercisePreview.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/17/25.
//

import SwiftUI

struct ExercisePreview: View {
    let exercise: WorkoutExercise
    let index: Int
    
    @State private var open: Bool = false
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                open.toggle()
            }
        } label: {
            HStack(alignment: .center) {
                Text(exercise.exercise?.name ?? "Exercise \(index + 1)")
                    .bodyText(size: 16)
                    .multilineTextAlignment(.leading)
                
                Image(systemName: "chevron.down")
                    .font(Font.system(size: 10, weight: .bold))
                    .rotationEffect(.degrees(open ? -180 : 0))
            }
        }
        .textColor()
        .animatedButton()
        
        if open {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(exercise.sets.sorted { $0.index < $1.index }, id: \.id) { set in
                    HStack {
                        ZStack {
                            switch set.type {
                            case .warmUp:
                                Image(systemName: "bolt.fill")
                                    .font(Font.system(size: 12))
                            case .dropSet:
                                Image(systemName: "arrowtriangle.down.fill")
                                    .font(Font.system(size: 12))
                            case .coolDown:
                                Image(systemName: "drop.fill")
                                    .font(Font.system(size: 12))
                            default:
                                Text("")
                            }
                        }
                        .frame(width: 10, height: 20)
                        
                        if set.exerciseType == .weight,
                           let reps = set.reps,
                           let weight = set.weight {
                            Text("\(reps) x \(String(format: "%0.2f", weight)) \(set.unit)")
                                .bodyText(size: 12)
                                .textColor()
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .animation(.easeInOut(duration: 0.3), value: weight)
                                .animation(.easeInOut(duration: 0.3), value: reps)
                        } else if set.exerciseType == .distance,
                                  let distance = set.distance {
                            Text("\(set.timeString) \(String(format: "%0.2f", distance)) \(set.unit)")
                                .bodyText(size: 12)
                                .textColor()
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .animation(.easeInOut(duration: 0.3), value: distance)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}
