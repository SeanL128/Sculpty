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
    
    @Query private var workouts: [Workout]
    @Query private var workoutLogs: [WorkoutLog]
    @Query private var caloriesLogs: [CaloriesLog]
    
    @State private var resetConfirmation1: Bool = false
    @State private var resetConfirmation2: Bool = false
    @State private var resetConfirmation3: Bool = false
    
    @AppStorage(UserKeys.units.rawValue) private var units: String = "Imperial"
    
    @AppStorage(UserKeys.appearance.rawValue) private var selectedAppearance: Appearance = .automatic
    @AppStorage(UserKeys.accent.rawValue) private var accentColorHex: String = "#C50A2B"
    
    @AppStorage(UserKeys.disableAutoLock.rawValue) private var disableAutoLock: Bool = false
    @AppStorage(UserKeys.show1RM.rawValue) private var show1RM: Bool = false
    @AppStorage(UserKeys.showRir.rawValue) private var showRir: Bool = false
    @AppStorage(UserKeys.showSetTimer.rawValue) private var showSetTimer: Bool = false
    @AppStorage(UserKeys.showTempo.rawValue) private var showTempo: Bool = false
    
    @AppStorage(UserKeys.dailyCalories.rawValue) private var dailyCalories: String = "0"
    @FocusState private var isDailyCaloriesFocused: Bool
    
    @AppStorage(UserKeys.includeWarmUp.rawValue) private var includeWarmUp: Bool = true
    @AppStorage(UserKeys.includeDropSet.rawValue) private var includeDropSet: Bool = true
    @AppStorage(UserKeys.includeCoolDown.rawValue) private var includeCoolDown: Bool = true
    
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
                    
                    Spacer()
                }
                .textColor()
                
                HStack {
                    Text("Units")
                        .bodyText(size: 18, weight: .bold)
                    
                    Spacer()
                    
                    Menu {
                        Picker(selection: $units) {
                            Text("Imperial (mi, ft, in, lbs)")
                                .tag("Imperial")
                            
                            Text("Metric (km, m, cm, kg)")
                                .tag("Metric")
                        } label: {}
                    } label: {
                        HStack {
                            if units == "Imperial" {
                                Text("Imperial (mi, ft, in, lbs)")
                                    .bodyText(size: 18)
                            } else {
                                Text("Metric (km, m, cm, kg)")
                                    .bodyText(size: 18)
                            }
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(Font.system(size: 14))
                        }
                    }
                    .id(units)
                    .textColor()
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Customization
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Image(systemName: "paintbrush.pointed")
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("CUSTOMIZATION")
                        .headingText(size: 24)
                }
                .textColor()
                
                HStack {
                    Text("Dark Mode")
                        .bodyText(size: 18, weight: .bold)
                    
                    Spacer()
                    
                    Menu {
                        Picker(selection: $selectedAppearance) {
                            ForEach(Appearance.displayOrder, id: \.id) { appearance in
                                Text("\(appearance.rawValue)")
                                    .tag(appearance)
                            }
                        } label: {}
                    } label: {
                        HStack {
                            Text(selectedAppearance.rawValue)
                                .bodyText(size: 18)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(Font.system(size: 14))
                        }
                    }
                    .id(selectedAppearance)
                    .textColor()
                }
                
                HStack {
                    Text("Accent Color")
                        .bodyText(size: 18, weight: .bold)
                    
                    Spacer()
                    
                    Menu {
                        Picker(selection: $accentColorHex) {
                            ForEach(AccentColor.displayOrder, id: \.id) { color in
                                Text("\(color.rawValue)")
                                    .tag(AccentColor.colorMap[color]!)
                            }
                        } label: {}
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color(hex: accentColorHex))
                                .frame(width: 10, height: 10)
                            
                            if let accent = AccentColor.fromHex(accentColorHex) {
                                Text(accent.rawValue)
                                    .bodyText(size: 18)
                            }
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(Font.system(size: 14))
                        }
                    }
                    .id(accentColorHex)
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
                
                Toggle(isOn: $disableAutoLock) {
                    Text("Disable Auto Lock")
                        .bodyText(size: 18, weight: .bold)
                        .textColor()
                }
                
                Toggle(isOn: $showRir) {
                    Text("Enable RIR")
                        .bodyText(size: 18, weight: .bold)
                        .textColor()
                }
                
                Toggle(isOn: $show1RM) {
                    Text("Enable 1RM")
                        .bodyText(size: 18, weight: .bold)
                        .textColor()
                }
                
                Toggle(isOn: $showTempo) {
                    Text("Enable Tempo")
                        .bodyText(size: 18, weight: .bold)
                        .textColor()
                }
                
                Toggle(isOn: $showSetTimer) {
                    Text("Enable Set Timers")
                        .bodyText(size: 18, weight: .bold)
                        .textColor()
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Calorie Tracking
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Image(systemName: "fork.knife")
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("CALORIE TRACKING")
                        .headingText(size: 24)
                }
                .textColor()
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Daily Calories Goal")
                            .bodyText(size: 18, weight: .bold)
                            .textColor()
                        
                        Spacer()
                        
                        Input(title: "", text: $dailyCalories, isFocused: _isDailyCaloriesFocused, unit: "cal", type: .numberPad)
                            .frame(maxWidth: 100)
                            .onChange(of: dailyCalories) {
                                dailyCalories = dailyCalories.filteredNumericWithoutDecimalPoint()
                                
                                if dailyCalories.isEmpty {
                                    dailyCalories = "0"
                                }
                            }
                    }
                    
                    NavigationLink(destination: CalorieCalculator()) {
                        HStack(alignment: .center) {
                            Text("Not sure? Calculate it here")
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 12, weight: .bold))
                        }
                    }
                    .bodyText(size: 16)
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
                
                Toggle(isOn: $includeWarmUp) {
                    Text("Include Warm Up Sets")
                        .bodyText(size: 18, weight: .bold)
                        .textColor()
                }
                
                Toggle(isOn: $includeDropSet) {
                    Text("Include Drop Sets")
                        .bodyText(size: 18, weight: .bold)
                        .textColor()
                }
                
                Toggle(isOn: $includeCoolDown) {
                    Text("Include Cool Down Sets")
                        .bodyText(size: 18, weight: .bold)
                        .textColor()
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
                }
                .textColor()
                
                HStack {
                    Button {
                        shareBackup()
                    } label: {
                        HStack(alignment: .center) {
                            Text("Back Up All Data")
                                .bodyText(size: 18, weight: .bold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 12, weight: .bold))
                        }
                    }
                    .textColor()
                }
                
                Button {
                    shareCSV(csvString: getWorkoutLogsCSV(), name: "SculptyWorkoutLogs")
                } label: {
                    HStack(alignment: .center) {
                        Text("Export Workout Logs to CSV")
                            .bodyText(size: 18, weight: .bold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 12, weight: .bold))
                    }
                }
                .textColor()
                
                Button {
                    shareCSV(csvString: getCaloriesCSV(), name: "SculptyCaloriesLogs")
                } label: {
                    HStack(alignment: .center) {
                        Text("Export Calories Data to CSV")
                            .bodyText(size: 18, weight: .bold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 12, weight: .bold))
                    }
                }
                .textColor()
                
                Button {
                    Task {
                        await ConfirmationPopup(selection: $resetConfirmation1, promptText: "Are you sure?", resultText: "This will reset all data.", cancelText: "Cancel", confirmText: "Reset").present()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Text("Reset Data")
                            .bodyText(size: 18, weight: .bold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 12, weight: .bold))
                    }
                }
                .textColor()
                .onChange(of: resetConfirmation1) {
                    if resetConfirmation1 {
                        Task {
                            await dismissAllPopups()
                            
                            await ConfirmationPopup(selection: $resetConfirmation2, promptText: "Are you 100% sure?", resultText: "This action cannot be undone.", cancelText: "Cancel", confirmText: "Reset").present()
                        }
                        
                        resetConfirmation1 = false
                    }
                }
                .onChange(of: resetConfirmation2) {
                    if resetConfirmation2 {
                        Task {
                            await dismissAllPopups()
                            
                            await ConfirmationPopup(selection: $resetConfirmation3, promptText: "You should consider backing up your data before resetting.", resultText: "If not, all data will be lost.", cancelText: "Cancel", confirmText: "Reset").present()
                        }
                        
                        resetConfirmation2 = false
                    }
                }
                .onChange(of: resetConfirmation3) {
                    if resetConfirmation3 {
                        Task {
                            await dismissAllPopups()
                        }
                        
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
                    .bodyText(size: 18, weight: .bold)
                
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
                
                Button {
                    isDailyCaloriesFocused = false
                } label: {
                    Text("Done")
                }
                .disabled(!isDailyCaloriesFocused)
            }
        }
    }
    
    private func shareBackup() {
        do {
            let fetchedExercises = try context.fetch(FetchDescriptor<Exercise>())
            let workouts = try context.fetch(FetchDescriptor<Workout>())
            let workoutLogs = try context.fetch(FetchDescriptor<WorkoutLog>())
            let measurements = try context.fetch(FetchDescriptor<Measurement>())
            let caloriesLogs = try context.fetch(FetchDescriptor<CaloriesLog>())

            let defaultExerciseIDs = Set(defaultExercises.map(\.id))
            let filteredExercises = fetchedExercises.filter { !defaultExerciseIDs.contains($0.id) }
            
            let data = AppDataDTO.export(
                exercises: filteredExercises,
                workouts: workouts,
                workoutLogs: workoutLogs,
                measurements: measurements,
                caloriesLogs: caloriesLogs
            )
            
            guard let data = data else {
                debugLog("Error encoding backup data")
                return
            }
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SculptyBackup.json")
            try data.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            
            Task {
                await InfoPopup(title: "Restoring from Backup", text: "To restore data from a backup, reset your data and select \"Returning? Import Backup\" from the start screen.").present()
            }
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
                        let workoutName = workoutLog.workout.name
                        let exerciseName = exerciseLog.exercise.exercise?.name ?? "N/A"
                        let muscleGroup = exerciseLog.exercise.exercise?.muscleGroup?.rawValue ?? "N/A"
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
                UserDefaults.standard.resetUser()
                
                dismiss()
            }
        } catch {
            debugLog("Failed to clear context: \(error.localizedDescription)")
        }
    }
}
