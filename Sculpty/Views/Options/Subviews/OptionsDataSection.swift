//
//  OptionsDataSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI
import SwiftData
import UIKit

struct OptionsDataSection: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var settings: CloudSettings
    
    @State private var isCreatingBackup: Bool = false
    @State private var isCreatingWorkoutLogsCSV: Bool = false
    @State private var isCreatingCaloriesLogsCSV: Bool = false
    
    @State private var resetConfirmation1: Bool = false
    @State private var resetConfirmation2: Bool = false
    @State private var resetConfirmation3: Bool = false
    
    private var hasWorkoutLogs: Bool {
        !((try? context.fetch(FetchDescriptor<WorkoutLog>()))?.isEmpty ?? true)
    }
    private var hasCaloriesLogs: Bool {
        !((try? context.fetch(FetchDescriptor<CaloriesLog>()))?.isEmpty ?? true)
    }
    
    private var isCreating: Bool {
        isCreatingBackup || isCreatingWorkoutLogsCSV || isCreatingCaloriesLogsCSV
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "Data Management", image: "folder")
            
            HStack {
                VStack(alignment: .leading, spacing: .spacingS) {
                    OptionsButtonRow(
                        title: isCreatingBackup ? "Creating Backup..." : "Back Up All Data",
                        isValid: !isCreating,
                        action: shareBackup,
                        feedback: .impact(weight: .medium)
                    )
                    
                    OptionsButtonRow(
                        title: isCreatingWorkoutLogsCSV ? "Creating CSV..." : "Export Workout Logs to CSV",
                        isValid: hasWorkoutLogs && !isCreating,
                        action: { shareCSV(csvString: getWorkoutLogsCSV(), name: "SculptyWorkoutLogs") },
                        feedback: .impact(weight: .medium)
                    )
                    
                    OptionsButtonRow(
                        title: isCreatingCaloriesLogsCSV ? "Creating CSV..." : "Export Calories Data to CSV",
                        isValid: hasCaloriesLogs && !isCreating,
                        action: { shareCSV(csvString: getCaloriesCSV(), name: "SculptyCaloriesLogs") },
                        feedback: .impact(weight: .medium)
                    )
                    
                    OptionsButtonRow(
                        title: "Reset Data",
                        isValid: !isCreating,
                        action: {
                            Popup.show(content: {
                                ConfirmationPopup(
                                    selection: $resetConfirmation1,
                                    promptText: "Are you sure?",
                                    resultText: "This will reset all data.",
                                    cancelText: "Cancel",
                                    confirmText: "Reset"
                                )
                            })
                        },
                        feedback: .warning
                    )
                    .onChange(of: resetConfirmation1) {
                        if resetConfirmation1 {
                            Popup.dismissAll()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                Popup.show(content: {
                                    ConfirmationPopup(
                                        selection: $resetConfirmation2,
                                        promptText: "Are you 100% sure?",
                                        resultText: "This cannot be undone.",
                                        cancelText: "Cancel",
                                        confirmText: "Reset"
                                    )
                                })
                            }
                            
                            resetConfirmation1 = false
                        }
                    }
                    .onChange(of: resetConfirmation2) {
                        if resetConfirmation2 {
                            Popup.dismissAll()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                Popup.show(content: {
                                    ConfirmationPopup(
                                        selection: $resetConfirmation3,
                                        promptText: "You should consider backing up your data before resetting.",
                                        resultText: "If not, all data will be lost.",
                                        cancelText: "Cancel",
                                        confirmText: "Reset"
                                    )
                                })
                            }
                            
                            resetConfirmation2 = false
                        }
                    }
                    .onChange(of: resetConfirmation3) {
                        if resetConfirmation3 {
                            Popup.dismissAll()
                            
                            clearContext()
                            
                            resetConfirmation3 = false
                        }
                    }
                }
                
                Spacer()
            }
            .card()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func shareBackup() {
        Task {
            await MainActor.run {
                isCreatingBackup = true
            }
            
            let container = context.container
            let backupData = await createBackupInBackground(container: container)
            
            await MainActor.run {
                isCreatingBackup = false
                
                guard let data = backupData else {
                    debugLog("Error creating backup data")
                    return
                }
                
                shareBackupFile(data: data)
            }
        }
    }

    private func createBackupInBackground(container: ModelContainer) async -> Data? {
        return await withCheckedContinuation { continuation in
            Task.detached {
                do {
                    let backgroundContext = ModelContext(container)
                    
                    let fetchedExercises = try backgroundContext.fetch(FetchDescriptor<Exercise>())
                    let workouts = try backgroundContext.fetch(FetchDescriptor<Workout>())
                    let workoutLogs = try backgroundContext.fetch(FetchDescriptor<WorkoutLog>())
                    let measurements = try backgroundContext.fetch(FetchDescriptor<Measurement>())
                    let caloriesLogs = try backgroundContext.fetch(FetchDescriptor<CaloriesLog>())

                    let defaultExerciseIDs = Set(defaultExercises.map { $0.id })
                    let filteredExercises = fetchedExercises.filter { !defaultExerciseIDs.contains($0.id) }
                    
                    let data = AppDataDTO.export(
                        exercises: filteredExercises,
                        workouts: workouts,
                        workoutLogs: workoutLogs,
                        measurements: measurements,
                        caloriesLogs: caloriesLogs,
                        includeSettings: true
                    )
                    
                    continuation.resume(returning: data)
                } catch {
                    debugLog("Error creating backup: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func shareBackupFile(data: Data) {
        do {
            dismissKeyboard()
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SculptyBackup.sculptydata")
            try data.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            
            Popup.show(content: {
                InfoPopup(
                    title: "Restoring from Backup",
                    text: "To restore data from a backup, reset your data and select \"Returning? Import Backup\" from the start screen." // swiftlint:disable:this line_length
                )
            })
        } catch {
            debugLog("Error writing backup file: \(error.localizedDescription)")
        }
    }
    
    private func getWorkoutLogsCSV() -> String {
        do {
            var rows: [String] = []
            rows.reserveCapacity(1000)
            
            rows.append("Date,Time,Workout,Exercise,Muscle Group,Set Type,Reps/Time,Weight/Distance,Unit,Skipped")
            
            let workoutLogs = try context.fetch(FetchDescriptor<WorkoutLog>())

            for workoutLog in workoutLogs {
                for exerciseLog in workoutLog.exerciseLogs {
                    for setLog in exerciseLog.setLogs where setLog.end.timeIntervalSince1970 > 0 {
                        let date = formatDate(setLog.end)
                        let time = formatTime(setLog.end)
                        let workoutName = workoutLog.workout?.name ?? "N/A"
                        let exerciseName = exerciseLog.exercise?.exercise?.name ?? "N/A"
                        let muscleGroup = exerciseLog.exercise?.exercise?.muscleGroup?.rawValue ?? "N/A"
                        let setType = setLog.set?.type.rawValue ?? "N/A"
                        let skipped = setLog.skipped ? "Yes" : "No"
                        
                        let repsOrTime: String
                        let weightOrDistance: String
                        let unit = setLog.unit
                        
                        if let set = setLog.set, set.exerciseType == .weight {
                            repsOrTime = "\(setLog.reps ?? 0)"
                            weightOrDistance = "\(setLog.weight ?? 0)"
                        } else {
                            if let timeValue = setLog.time {
                                let totalSeconds = Int(timeValue)
                                let hours = totalSeconds / 3600
                                let minutes = (totalSeconds % 3600) / 60
                                let seconds = totalSeconds % 60
                                
                                if hours > 0 {
                                    repsOrTime = String(format: "%d:%02d:%02d", hours, minutes, seconds)
                                } else {
                                    repsOrTime = String(format: "%02d:%02d", minutes, seconds)
                                }
                            } else {
                                repsOrTime = "00:00"
                            }
                            
                            weightOrDistance = "\(setLog.distance ?? 0)"
                        }
                        
                        rows.append("\"\(date)\",\"\(time)\",\"\(workoutName)\",\"\(exerciseName)\",\"\(muscleGroup)\",\"\(setType)\",\"\(repsOrTime)\",\"\(weightOrDistance)\",\"\(unit)\",\"\(skipped)\"") // swiftlint:disable:this line_length
                    }
                }
            }

            return rows.joined(separator: "\n")
        } catch {
            debugLog("Error writing CSV file: \(error.localizedDescription)")
            return ""
        }
    }
    
    private func getCaloriesCSV() -> String {
        do {
            var rows: [String] = []
            rows.reserveCapacity(500)
            
            rows.append("Date,Time,Name,Calories,Carbs,Protein,Fat")
            
            let caloriesLogs = try context.fetch(FetchDescriptor<CaloriesLog>())
            
            for log in caloriesLogs {
                for entry in log.entries {
                    rows.append("\"\(formatDate(log.date))\",\"\(formatTime(log.date))\",\"\(entry.name)\",\"\(entry.calories) cal\",\"\(entry.carbs)g\",\"\(entry.protein)g\",\"\(entry.fat)g\"") // swiftlint:disable:this line_length
                }
            }
            
            return rows.joined(separator: "\n")
        } catch {
            debugLog("Error writing CSV file: \(error.localizedDescription)")
            return ""
        }
    }
    
    private func shareCSV(csvString: String, name: String) {
        guard !csvString.isEmpty, let data = csvString.data(using: .utf8) else { return }
        
        dismissKeyboard()
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).csv")
        
        do {
            try data.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            debugLog("Error writing CSV file: \(error.localizedDescription)")
        }
    }
    
    private func clearContext() {
        do {
            try DataTransferManager.shared.clearAllData(in: context)
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                settings.resetAllSettings()
                
                dismiss()
            }
        } catch {
            debugLog("Failed to clear context: \(error.localizedDescription)")
        }
    }
}
