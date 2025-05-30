//
//  ViewWorkoutLog.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI
import SwiftData
import MijickPopups

struct ViewWorkoutLog: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    private var log: WorkoutLog
    
    @State private var confirmDelete: Bool = false
    @State private var exerciseLogToDelete: ExerciseLog? = nil
    @State private var setLogToDelete: (ExerciseLog, SetLog)? = nil
    
    @State private var includeWarmUp: Bool = true
    @State private var includeDropSet: Bool = true
    @State private var includeCoolDown: Bool = true
    
    @State private var showRir: Bool = false
    
    init(log: WorkoutLog) {
        self.log = log
    }
    
    var body: some View {
        ContainerView(title: log.workout?.name ?? "Workout") {
            Text(formatDate(log.start))
                .bodyText(size: 20, weight: .bold)
                .textColor()
            
            VStack (alignment: .leading, spacing: 8){
                Text("Total Time: \(lengthToString(length: log.getLength()))")
                    .bodyText(size: 16)
                    .textColor()
                
                Text("Total Reps: \(log.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown)) reps")
                    .bodyText(size: 16)
                    .textColor()
                
                Text("Total Weight: \(log.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown).formatted())\(UnitsManager.weight)")
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
            
            Spacer()
                .frame(height: 5)
            
            ForEach(log.exerciseLogs.sorted { $0.index < $1.index }, id: \.id) { exerciseLog in
                let setLogs = exerciseLog.setLogs.filter { $0.completed }
                
                if !setLogs.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .center) {
                            Text(exerciseLog.exercise?.exercise?.name.uppercased() ?? "EXERCISE")
                                .headingText(size: 14)
                                .textColor()
                            
                            Button {
                                exerciseLogToDelete = exerciseLog
                                
                                Task {
                                    await ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(exerciseLog.exercise?.exercise?.name ?? "exercise") logs?", resultText: "This cannot be undone.", cancelText: "Cancel", confirmText: "Delete").present()
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .padding(.horizontal, 2)
                                    .font(Font.system(size: 10))
                            }
                            .textColor()
                        }
                        .padding(.bottom, -8)
                        
                        ForEach(setLogs.sorted { $0.index < $1.index }, id: \.id) { setLog in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .center) {
                                    let set = setLog.set ?? ExerciseSet()
                                    
                                    if set.exerciseType == .weight,
                                       let reps = set.reps,
                                       let weight = set.weight,
                                       let rir = set.rir {
                                        Text("\(reps) x \(String(format: "%0.2f", weight)) \(set.unit) \((showRir && [.main, .dropSet].contains(set.type)) ? "(\(rir)\((rir) == "Failure" ? "" : " RIR"))" : "")")
                                            .bodyText(size: 16)
                                            .textColor()
                                    } else if set.exerciseType == .distance,
                                              let distance = set.distance {
                                        Text("\(set.timeString) \(String(format: "%0.2f", distance)) \(set.unit)")
                                            .bodyText(size: 16)
                                            .textColor()
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        setLogToDelete = (exerciseLog, setLog)
                                        
                                        Task {
                                            await ConfirmationPopup(selection: $confirmDelete, promptText: "Delete set log from \(formatDateWithTime(setLog.start)))?", resultText: "This cannot be undone.", cancelText: "Cancel", confirmText: "Delete").present()
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .padding(.horizontal, 8)
                                            .font(Font.system(size: 16))
                                    }
                                    .textColor()
                                }
                                .padding(.trailing, 1)
                                
                                Text(formatDateWithTime(setLog.start))
                                    .bodyText(size: 12)
                                    .secondaryColor()
                            }
                        }
                    }
                }
            }
        }
        .onAppear() {
            includeWarmUp = settings.includeWarmUp
            includeDropSet = settings.includeDropSet
            includeCoolDown = settings.includeCoolDown
            
            showRir = settings.showRir
        }
        .onChange(of: confirmDelete) {
            if confirmDelete {
                if let exerciseLog = exerciseLogToDelete {
                    log.exerciseLogs.remove(at: log.exerciseLogs.firstIndex(where: { $0.id == exerciseLog.id })!)
                    context.delete(exerciseLog)
                }
                
                if let exerciseLog = setLogToDelete?.0,
                   let setLog = setLogToDelete?.1 {
                    exerciseLog.setLogs.remove(at: exerciseLog.setLogs.firstIndex(where: { $0.id == setLog.id })!)
                    context.delete(setLog)
                }
                
                try? context.save()
                
                confirmDelete = false
                exerciseLogToDelete = nil
                setLogToDelete = nil
            }
        }
    }
}
