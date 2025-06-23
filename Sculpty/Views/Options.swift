//
//  Options.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/20/25.
//

import SwiftUI
import SwiftData
import UIKit

struct Options: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var settings: CloudSettings
    
    @Query private var workouts: [Workout]
    @Query private var workoutLogs: [WorkoutLog]
    @Query private var caloriesLogs: [CaloriesLog]
    
    @State private var resetConfirmation1: Bool = false
    @State private var resetConfirmation2: Bool = false
    @State private var resetConfirmation3: Bool = false
    
    @FocusState private var isTargetWeeklyWorkoutsFocused: Bool
    @FocusState private var isDailyCaloriesFocused: Bool
    
    var body: some View {
        ContainerView(title: "Options", spacing: 24) {
            // MARK: Defaults
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Image(systemName: "doc.plaintext")
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("DEFAULTS")
                        .headingText(size: 24)
                }
                .textColor()
                
                HStack {
                    Text("Units")
                        .bodyText(size: 18)
                    
                    Spacer()
                    
                    Button {
                        Popup.show(content: {
                            UnitMenuPopup(selection: $settings.units)
                        })
                    } label: {
                        HStack(alignment: .center) {
                            Text(settings.units == "Imperial" ? "Imperial (mi, ft, in, lbs)" : "Metric (km, m, cm, kg)")
                                .bodyText(size: 18, weight: .bold)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(Font.system(size: 12, weight: .bold))
                        }
                    }
                    .textColor()
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Workouts
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Image(systemName: "dumbbell")
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("WORKOUTS")
                        .headingText(size: 24)
                }
                .textColor()
                
                HStack {
                    Text("Weekly Workouts Goal")
                        .bodyText(size: 18)
                        .textColor()
                    
                    Spacer()
                    
                    Input(title: "", text: $settings.targetWeeklyWorkoutsString, isFocused: _isTargetWeeklyWorkoutsFocused, type: .numberPad)
                        .frame(maxWidth: 100)
                        .onChange(of: settings.targetWeeklyWorkoutsString) {
                            settings.targetWeeklyWorkoutsString = settings.targetWeeklyWorkoutsString.filteredNumericWithoutDecimalPoint()
                            
                            if settings.targetWeeklyWorkoutsString.isEmpty {
                                settings.targetWeeklyWorkoutsString = "0"
                            }
                        }
                }
                
                Toggle(isOn: $settings.showRir) {
                    Text("Enable RIR")
                        .bodyText(size: 18)
                        .textColor()
                }
                .padding(.trailing, 2)
                
                Toggle(isOn: $settings.show1RM) {
                    Text("Enable 1RM")
                        .bodyText(size: 18)
                        .textColor()
                }
                .padding(.trailing, 2)
                
                Toggle(isOn: $settings.showTempo) {
                    Text("Enable Tempo")
                        .bodyText(size: 18)
                        .textColor()
                }
                .padding(.trailing, 2)
                
                Toggle(isOn: $settings.showSetTimer) {
                    Text("Enable Set Timers")
                        .bodyText(size: 18)
                        .textColor()
                }
                .padding(.trailing, 2)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Calories
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Image(systemName: "fork.knife")
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("CALORIES")
                        .headingText(size: 24)
                }
                .textColor()
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Daily Calories Goal")
                            .bodyText(size: 18)
                            .textColor()
                        
                        Spacer()
                        
                        Input(title: "", text: $settings.dailyCaloriesString, isFocused: _isDailyCaloriesFocused, unit: "cal", type: .numberPad)
                            .frame(maxWidth: 100)
                            .onChange(of: settings.dailyCaloriesString) {
                                settings.dailyCaloriesString = settings.dailyCaloriesString.filteredNumericWithoutDecimalPoint()
                                
                                if settings.dailyCaloriesString.isEmpty {
                                    settings.dailyCaloriesString = "0"
                                }
                            }
                    }
                    
                    NavigationLink(destination: CalorieCalculator()) {
                        HStack(alignment: .center) {
                            Text("Not sure? Calculate it here")
                                .bodyText(size: 14, weight: .bold)
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 10, weight: .bold))
                        }
                    }
                    .textColor()
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Stats
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Image(systemName: "chart.xyaxis.line")
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("STATS")
                        .headingText(size: 24)
                }
                .textColor()
                
                Toggle(isOn: $settings.includeWarmUp) {
                    Text("Include Warm Up Sets")
                        .bodyText(size: 18)
                        .textColor()
                }
                .padding(.trailing, 2)
                
                Toggle(isOn: $settings.includeDropSet) {
                    Text("Include Drop Sets")
                        .bodyText(size: 18)
                        .textColor()
                }
                .padding(.trailing, 2)
                
                Toggle(isOn: $settings.includeCoolDown) {
                    Text("Include Cool Down Sets")
                        .bodyText(size: 18)
                        .textColor()
                }
                .padding(.trailing, 2)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Notifications
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Image(systemName: "bell")
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("NOTIFICATIONS")
                        .headingText(size: 24)
                }
                .textColor()
                
                Toggle(isOn: $settings.enableNotifications) {
                    Text("Enable Notifications")
                        .bodyText(size: 18)
                        .textColor()
                }
                .padding(.trailing, 2)
                .onChange(of: settings.enableNotifications) {
                    if settings.enableNotifications {
                        handleNotificationToggle()
                    }
                }
                
                if settings.enableNotifications {
                    Toggle(isOn: $settings.enableCaloriesNotifications) {
                        Text("Enable Daily Calories Reminders")
                            .bodyText(size: 18)
                            .textColor()
                    }
                    .padding(.trailing, 2)
                    
                    Toggle(isOn: $settings.enableMeasurementsNotifications) {
                        Text("Enable Weekly Measurement Reminders")
                            .bodyText(size: 18)
                            .textColor()
                    }
                    .padding(.trailing, 2)
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Data Management
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Image(systemName: "folder")
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("DATA MANAGEMENT")
                        .headingText(size: 24)
                    
                    Spacer()
                }
                .textColor()
                
                HStack {
                    Button {
                        shareBackup()
                    } label: {
                        HStack(alignment: .center) {
                            Text("Back Up All Data")
                                .bodyText(size: 18)
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 12))
                        }
                    }
                    .textColor()
                }
                
                Button {
                    shareCSV(csvString: getWorkoutLogsCSV(), name: "SculptyWorkoutLogs")
                } label: {
                    HStack(alignment: .center) {
                        Text("Export Workout Logs to CSV")
                            .bodyText(size: 18)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 12))
                    }
                }
                .textColor()
                
                Button {
                    shareCSV(csvString: getCaloriesCSV(), name: "SculptyCaloriesLogs")
                } label: {
                    HStack(alignment: .center) {
                        Text("Export Calories Data to CSV")
                            .bodyText(size: 18)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 12))
                    }
                }
                .textColor()
                
                Button {
                    Popup.show(content: {
                        ConfirmationPopup(selection: $resetConfirmation1, promptText: "Are you sure?", resultText: "This will reset all data.", cancelText: "Cancel", confirmText: "Reset")
                    })
                } label: {
                    HStack(alignment: .center) {
                        Text("Reset Data")
                            .bodyText(size: 18)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 12))
                    }
                }
                .textColor()
                .onChange(of: resetConfirmation1) {
                    if resetConfirmation1 {
                        Popup.dismissAll()
                        
                        Popup.show(content: {
                            ConfirmationPopup(selection: $resetConfirmation2, promptText: "Are you 100% sure?", resultText: "This cannot be undone.", cancelText: "Cancel", confirmText: "Reset")
                        })
                        
                        resetConfirmation1 = false
                    }
                }
                .onChange(of: resetConfirmation2) {
                    if resetConfirmation2 {
                        Popup.dismissAll()
                        
                        Popup.show(content: {
                            ConfirmationPopup(selection: $resetConfirmation3, promptText: "You should consider backing up your data before resetting.", resultText: "If not, all data will be lost.", cancelText: "Cancel", confirmText: "Reset")
                        })
                        
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
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Misc
            VStack(alignment: .center, spacing: 8) {
                Link("Website", destination: URL(string: "https://sculpty.app")!)
                    .bodyText(size: 18)
                
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("Sculpty Version \(version) Build \(build)")
                        .statsText(size: 14)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                KeyboardDoneButton(focusStates: [_isDailyCaloriesFocused, _isTargetWeeklyWorkoutsFocused])
            }
        }
    }
    
    private func handleNotificationToggle() {
        NotificationManager.shared.requestPermissionIfNeeded { granted in
            if !granted {
                settings.enableNotifications = false
                
                Popup.show(content: {
                    InfoPopup(title: "Enable Notifications", text: "To receive reminders, please enable notifications in Settings > Sculpty > Notifications")
                })
                
                openSettings()
            }
        }
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func shareBackup() {
        do {
            let fetchedExercises = try context.fetch(FetchDescriptor<Exercise>())
            let workouts = try context.fetch(FetchDescriptor<Workout>())
            let workoutLogs = try context.fetch(FetchDescriptor<WorkoutLog>())
            let measurements = try context.fetch(FetchDescriptor<Measurement>())
            let caloriesLogs = try context.fetch(FetchDescriptor<CaloriesLog>())

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
            
            guard let data = data else {
                debugLog("Error encoding backup data")
                return
            }
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SculptyBackup.sculptydata")
            try data.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            
            Popup.show(content: {
                InfoPopup(title: "Restoring from Backup", text: "To restore data from a backup, reset your data and select \"Returning? Import Backup\" from the start screen.")
            })
        } catch {
            debugLog("Error creating backup file: \(error.localizedDescription)")
        }
    }
    
    
    private func getWorkoutLogsCSV() -> String {
        var csv = "Date,Time,Workout,Exercise,Muscle Group,Set Type,Reps/Time,Weight/Distance,Unit,Skipped\n"

        for workoutLog in workoutLogs {
            for exerciseLog in workoutLog.exerciseLogs {
                for setLog in exerciseLog.setLogs {
                    if setLog.end.timeIntervalSince1970 > 0 {
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
                        
                        csv += "\"\(date)\",\"\(time)\",\"\(workoutName)\",\"\(exerciseName)\",\"\(muscleGroup)\",\"\(setType)\",\"\(repsOrTime)\",\"\(weightOrDistance)\",\"\(unit)\",\"\(skipped)\"\n"
                    }
                }
            }
        }

        return csv
    }
    
    private func getCaloriesCSV() -> String {
        var csv = "Date,Time,Name,Calories,Carbs,Protein,Fat\n"
        
        for log in caloriesLogs {
            for entry in log.entries {
                csv += "\"\(formatDate(log.date))\",\"\(formatTime(log.date))\",\"\(entry.name)\",\"\(entry.calories) cal\",\"\(entry.carbs)g\",\"\(entry.protein)g\",\"\(entry.fat)g\"\n"
            }
        }
        
        return csv
    }
    
    private func shareCSV(csvString: String, name: String) {
        guard let data = csvString.data(using: .utf8) else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).csv")
        
        do {
            try data.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            debugLog("Error writing CSV file: \(error)")
        }
    }
    
    
    private func clearContext() {
        do {
            try DataTransferManager.shared.clearAllData(in: context)
            
            withAnimation {
                settings.resetAllSettings()
                
                dismiss()
            }
        } catch {
            debugLog("Failed to clear context: \(error.localizedDescription)")
        }
    }
}
