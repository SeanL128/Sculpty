//
//  ExerciseLogGroup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI
import SwiftData

struct ExerciseLogGroup: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    let exerciseLog: ExerciseLog
    let workoutLog: WorkoutLog
    
    private var setLogs: [SetLog] {
        exerciseLog.setLogs.filter { $0.completed }
    }
    
    var body: some View {
        if !setLogs.isEmpty {
            VStack(alignment: .leading, spacing: .spacingS) {
                Text(exerciseLog.exercise?.exercise?.name ?? "Exercise")
                    .subheadingText()
                    .textColor()
                
                VStack(alignment: .leading, spacing: .listSpacing) {
                    ForEach(setLogs.sorted { $0.index < $1.index }, id: \.id) { setLog in
                        SetLogRow(setLog: setLog, exerciseLog: exerciseLog)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .leading)),
                                removal: .opacity.combined(with: .move(edge: .trailing))
                            ))
                    }
                    .animation(.easeInOut(duration: 0.3), value: setLogs)
                }
            }
        }
    }
}
