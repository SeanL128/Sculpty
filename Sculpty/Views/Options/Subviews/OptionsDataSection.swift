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
    
    @StateObject private var iCloudManager = iCloudBackupManager()
    
    @State private var isCreatingBackup: Bool = false
    @State private var isCreatingWorkoutLogsCSV: Bool = false
    @State private var isCreatingCaloriesLogsCSV: Bool = false
    
    private var hasWorkoutLogs: Bool {
        !((try? context.fetch(FetchDescriptor<WorkoutLog>()))?.isEmpty ?? true)
    }
    private var hasCaloriesLogs: Bool {
        !((try? context.fetch(FetchDescriptor<CaloriesLog>()))?.filter { !$0.entries.isEmpty }.isEmpty ?? true)
    }
    
    private var isCreating: Bool {
        isCreatingBackup || isCreatingWorkoutLogsCSV || isCreatingCaloriesLogsCSV || iCloudManager.isBackingUp
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "Data Management", image: "folder")
            
            HStack {
                VStack(alignment: .leading, spacing: .spacingM) {
                    VStack(alignment: .leading, spacing: .spacingS) {
                        OptionsButtonRow(
                            title: isCreatingBackup ? "Creating Backup..." : "Backup Data Locally",
                            isValid: !isCreating,
                            action: shareBackup,
                            feedback: .impact(weight: .medium)
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: .spacingS) {
                        if iCloudManager.isICloudAvailable {
                            OptionsButtonRow(
                                title: iCloudManager.isBackingUp ? "Saving to iCloud..." : "Backup to iCloud",
                                isValid: !isCreating,
                                action: {
                                    Task {
                                        await iCloudManager.backupToiCloud(context: context)
                                        
                                        Toast.show(
                                            "Saved to iCloud successfully",
                                            "square.and.arrow.up.badge.checkmark"
                                        )
                                    }
                                },
                                feedback: .impact(weight: .medium)
                            )
                            
                            OptionsToggleRow(
                                text: "Automatic iCloud Backups",
                                isOn: $settings.enableAutoBackup
                            )
                            .onAppear {
                                if settings.enableAutoBackup {
                                    iCloudManager.setupAutoBackup(with: context.container)
                                }
                            }
                            .onChange(of: settings.enableAutoBackup) {
                                if settings.enableAutoBackup {
                                    iCloudManager.setupAutoBackup(with: context.container)
                                }
                            }
                        } else {
                            Text("iCloud not available")
                                .bodyText()
                                .secondaryColor()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: .spacingS) {
                        OptionsButtonRow(
                            title: "Restore from Backup",
                            isValid: !isCreating,
                            action: {
                                Popup.show(content: {
                                    BackupRestorePopup(iCloudManager: iCloudManager)
                                })
                            },
                            feedback: .impact(weight: .medium)
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: .spacingS) {
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
                    let customFoods = try backgroundContext.fetch(FetchDescriptor<CustomFood>())
                    let caloriesLogs = try backgroundContext.fetch(FetchDescriptor<CaloriesLog>())

                    let defaultExerciseIDs = Set(defaultExercises.map { $0.id })
                    let filteredExercises = fetchedExercises.filter { !defaultExerciseIDs.contains($0.id) }
                    
                    let data = AppDataDTO.export(
                        exercises: filteredExercises,
                        workouts: workouts,
                        workoutLogs: workoutLogs,
                        measurements: measurements,
                        customFoods: customFoods,
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
}
