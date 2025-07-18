//
//  SetLogRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI
import SwiftData

struct SetLogRow: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    let setLog: SetLog
    let exerciseLog: ExerciseLog
    
    @State private var confirmDelete: Bool = false
    @State private var setLogToDelete: (ExerciseLog, SetLog)?
    
    var body: some View {
        if let set = setLog.set {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center) {
                    if set.exerciseType == .weight,
                       let reps = set.reps,
                       let weight = set.weight,
                       let rir = set.rir {
                        Text("\(reps) x \(String(format: "%0.2f", weight)) \(set.unit) \((settings.showRir && [.main, .dropSet].contains(set.type)) ? "(\(rir)\((rir) == "Failure" ? "" : " RIR"))" : "")") // swiftlint:disable:this line_length
                            .bodyText(size: 16)
                            .textColor()
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: weight)
                            .animation(.easeInOut(duration: 0.3), value: reps)
                    } else if set.exerciseType == .distance,
                              let distance = set.distance {
                        Text("\(set.timeString) \(String(format: "%0.2f", distance)) \(set.unit)")
                            .bodyText(size: 16)
                            .textColor()
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: distance)
                    }
                    
                    Spacer()
                    
                    Button {
                        setLogToDelete = (exerciseLog, setLog)
                        
                        Popup.show(content: {
                            ConfirmationPopup(
                                selection: $confirmDelete,
                                promptText: "Delete set log from \(formatDateWithTime(setLog.start)))?",
                                resultText: "This cannot be undone.",
                                cancelText: "Cancel",
                                confirmText: "Delete"
                            )
                        })
                    } label: {
                        Image(systemName: "xmark")
                            .padding(.horizontal, 8)
                            .font(Font.system(size: 16))
                    }
                    .textColor()
                    .animatedButton(feedback: .warning)
                }
                .padding(.trailing, 1)
                
                Text(formatDateWithTime(setLog.start))
                    .bodyText(size: 12)
                    .secondaryColor()
            }
            .onChange(of: confirmDelete) {
                if confirmDelete,
                   let exerciseLog = setLogToDelete?.0,
                   let setLog = setLogToDelete?.1,
                   let index = exerciseLog.setLogs.firstIndex(where: { $0.id == setLog.id }) {
                    exerciseLog.setLogs.remove(at: index)
                    context.delete(setLog)
                    
                    do {
                        try context.save()
                    } catch {
                        debugLog("Error: \(error.localizedDescription)")
                    }
                    
                    confirmDelete = false
                    setLogToDelete = nil
                }
            }
        } else {
            Text("Error")
                .bodyText(size: 16)
                .secondaryColor()
        }
    }
}
