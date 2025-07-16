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
    
    @State private var confirmDelete: Bool = false
    @State private var exerciseLogToDelete: ExerciseLog?
    
    var body: some View {
        if !setLogs.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Text(exerciseLog.exercise?.exercise?.name.uppercased() ?? "EXERCISE")
                        .headingText(size: 14)
                        .textColor()
                    
                    Button {
                        exerciseLogToDelete = exerciseLog
                        
                        Popup.show(content: {
                            ConfirmationPopup(
                                selection: $confirmDelete,
                                promptText: "Delete \(exerciseLog.exercise?.exercise?.name ?? "exercise") logs?", // swiftlint:disable:this line_length
                                resultText: "This cannot be undone.",
                                cancelText: "Cancel",
                                confirmText: "Delete"
                            )
                        })
                    } label: {
                        Image(systemName: "xmark")
                            .padding(.horizontal, 2)
                            .font(Font.system(size: 10))
                    }
                    .textColor()
                    .animatedButton(feedback: .warning)
                }
                .padding(.bottom, -8)
                
                ForEach(setLogs.sorted { $0.index < $1.index }, id: \.id) { setLog in
                    SetLogRow(setLog: setLog, exerciseLog: exerciseLog)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                }
                .animation(.easeInOut(duration: 0.3), value: setLogs.count)
            }
            .onChange(of: confirmDelete) {
                if confirmDelete,
                   let exerciseLog = exerciseLogToDelete,
                   let index = workoutLog.exerciseLogs.firstIndex(where: { $0.id == exerciseLog.id }) {
                    workoutLog.exerciseLogs.remove(at: index)
                    context.delete(exerciseLog)
                    
                    do {
                        try context.save()
                    } catch {
                        debugLog("Error: \(error.localizedDescription)")
                    }
                    
                    confirmDelete = false
                    exerciseLogToDelete = nil
                }
            }
        } else {
            Text("Error")
                .bodyText(size: 14)
                .secondaryColor()
        }
    }
}
