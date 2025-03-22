//
//  Options.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/20/25.
//

import SwiftUI
import SwiftData
import UIKit
import Neumorphic

struct Options: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @Query private var workouts: [Workout]
    @Query(filter: #Predicate<Exercise> { !defaultExercises.contains($0) }) private var exercises: [Exercise]
    @Query private var workoutLogs: [WorkoutLog]
    @Query private var caloriesLogs: [CaloriesLog]
    
    @State private var showRestoreInfo: Bool = false
    
    @State private var showResetConfirmation1: Bool = false
    @State private var showResetConfirmation2: Bool = false
    @State private var showResetConfirmation3: Bool = false
    
    @AppStorage(UserKeys.units.rawValue) private var units: String = "Imperial"
    
    @AppStorage(UserKeys.appearance.rawValue) private var selectedAppearance: Appearance = .automatic
    @AppStorage(UserKeys.accent.rawValue) private var accentColorHex: String = "#C50A2B"
    
    @AppStorage(UserKeys.disableAutoLock.rawValue) private var disableAutoLock: Bool = false
    @AppStorage(UserKeys.showRir.rawValue) private var showRir: Bool = false
    @AppStorage(UserKeys.showTempo.rawValue) private var showTempo: Bool = false
    
    @AppStorage(UserKeys.defaultReps.rawValue) private var defaultReps: Int = 12
    @AppStorage(UserKeys.defaultWeight.rawValue) private var defaultWeight: Double = 40
    @AppStorage(UserKeys.defaultUnits.rawValue) private var defaultUnits: String = UnitsManager.weight
    @AppStorage(UserKeys.defaultMeasurement.rawValue) private var defaultMeasurement: String = "x"
    @AppStorage(UserKeys.defaultType.rawValue) private var defaultType: String = "Main"
    @AppStorage(UserKeys.defaultRir.rawValue) private var defaultRir: String = "0"
    @State private var defaultSet: ExerciseSet = ExerciseSet()
    
    @AppStorage(UserKeys.dailyCalories.rawValue) private var dailyCalories: String = "0"
    @FocusState private var isDailyCaloriesFocused: Bool
    
    @AppStorage(UserKeys.includeWarmUp.rawValue) private var includeWarmUp: Bool = true
    @AppStorage(UserKeys.includeDropSet.rawValue) private var includeDropSet: Bool = true
    @AppStorage(UserKeys.includeCoolDown.rawValue) private var includeCoolDown: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                ScrollView {
                    HStack(alignment: .center) {
                        Text("Options")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    .padding()
                    
                    VStack(spacing: 25) {
                        // MARK: Defaults
                        VStack(spacing: 5) {
                            Text("Defaults")
                                .font(.callout)
                            
                            HStack {
                                Text("Units")
                                    .font(.callout)
                                
                                Spacer()
                                
                                Picker("Default Units", selection: $units) {
                                    Text("Imperial (mi, ft, in, lbs)").tag("Imperial")
                                    
                                    Text("Metric (km, m, cm, kg").tag("Metric")
                                }
                                .pickerStyle(.menu)
                                .tint(ColorManager.text)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                        
                        // MARK: Customization
                        VStack(spacing: 5) {
                            Text("Customization")
                                .font(.callout)
                            
                            HStack {
                                Text("Dark Mode")
                                
                                Spacer()
                                
                                Picker("Dark Mode", selection: $selectedAppearance) {
                                    ForEach(Appearance.displayOrder, id: \.id) { appearance in
                                        Text("\(appearance.rawValue)")
                                            .tag(appearance)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(ColorManager.text)
                            }
                            
                            HStack {
                                Text("Accent Color")
                                
                                Spacer()
                                
                                Picker("Accent Color", selection: $accentColorHex) {
                                    ForEach(AccentColor.displayOrder, id: \.id) { color in
                                        HStack {
                                            Circle()
                                                .fill(Color(hex: AccentColor.colorMap[color]!))
                                                .frame(width: 10, height: 10)
                                            Text("\(color.rawValue)")
                                        }
                                        .tag(AccentColor.colorMap[color]!)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(ColorManager.text)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                        
                        // MARK: Workouts
                        VStack(spacing: 5) {
                            Text("Workouts")
                                .font(.callout)
                            
                            Toggle(isOn: $disableAutoLock) {
                                Text("Disable Auto Lock")
                            }
                            
                            Toggle(isOn: $showRir) {
                                Text("Enable RIR")
                            }
                            
                            Toggle(isOn: $showTempo) {
                                Text("Enable Tempo")
                            }
                            
                            Button {
                                Task {
                                    await EditSetPopup(set: $defaultSet).present()
                                }
                            } label: {
                                HStack {
                                    Text("Edit Default Set")
                                    
                                    Spacer()
                                }
                            }
                            .onChange(of: defaultSet) {
                                defaultReps = defaultSet.reps
                                defaultWeight = defaultSet.weight
                                defaultUnits = defaultSet.unit
                                defaultMeasurement = defaultSet.measurement
                                defaultType = defaultSet.type.rawValue
                                defaultRir = defaultSet.rir
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                        
                        // MARK: Calorie Tracking
                        VStack(spacing: 5) {
                            Text("Calorie Tracking")
                                .font(.callout)
                            
                            HStack {
                                HStack {
                                    Text("Daily Calories Goal:")
                                    
                                    Spacer()
                                }
                                .frame(width: 200)
                                
                                TextField("", text: $dailyCalories, prompt: Text("Daily Calories").foregroundColor(.secondary))
                                    .keyboardType(.numberPad)
                                    .focused($isDailyCaloriesFocused)
                                    .padding(8)
                                    .padding(.horizontal, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                            .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.25, radius: 2)
                                    )
                                    .onChange(of: dailyCalories) {
                                        dailyCalories = dailyCalories.filteredNumericWithoutDecimalPoint()
                                        
                                        if dailyCalories.isEmpty {
                                            dailyCalories = "0"
                                        }
                                    }
                                
                                Text("cal")
                            }
                            
                            NavigationLink(destination: CalorieCalculator()) {
                                Text("Not sure? Calculate it here")
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                        
                        // MARK: Stats
                        VStack(spacing: 5) {
                            Text("Stats")
                                .font(.callout)
                            
                            Toggle(isOn: $includeWarmUp) {
                                Text("Include Warm Up Sets")
                            }
                            
                            Toggle(isOn: $includeDropSet) {
                                Text("Include Drop Sets")
                            }
                            
                            Toggle(isOn: $includeCoolDown) {
                                Text("Include Cool Down Sets")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                        
                        // MARK: Data Management
                        VStack(spacing: 15) {
                            Text("Data Management")
                                .font(.callout)
                                .padding(.bottom, -5)
                            
                            HStack {
                                Button {
                                    shareBackup()
                                } label: {
                                    Text("Back Up All Data")
                                }
                                .softButtonStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                                
                                Button {
                                    showRestoreInfo = true
                                } label: {
                                    Image(systemName: "info.circle")
                                }
                                .softButtonStyle(.circle, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                                .alert(isPresented: $showRestoreInfo) {
                                    Alert(title: Text("Restoring from Backup"),
                                          message: Text("To restore data from a backup, reset your data and select \"Returning? Import Backup\" from the start screen."))
                                }
                            }
                            
                            Button {
                                shareCSV(csvString: getWorkoutLogsCSV(), name: "SculptyWorkoutLogs")
                            } label: {
                                Text("Export Workout Logs to CSV")
                            }
                            .softButtonStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                            
                            Button {
                                shareCSV(csvString: getCaloriesCSV(), name: "SculptyCaloriesLogs")
                            } label: {
                                Text("Export Calories Data to CSV")
                            }
                            .softButtonStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                            
                            Button {
                                showResetConfirmation1 = true
                            } label: {
                                Text("Reset Data")
                            }
                            .softButtonStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                            .confirmationDialog("Are you sure? This will reset all data.", isPresented: $showResetConfirmation1, titleVisibility: .visible) {
                                Button("Reset", role: .destructive) {
                                    showResetConfirmation2 = true
                                }
                            }
                            .confirmationDialog("Are you 100% sure? This action cannot be undone.", isPresented: $showResetConfirmation2, titleVisibility: .visible) {
                                Button("Reset", role: .destructive) {
                                    showResetConfirmation3 = true
                                }
                            }
                            .confirmationDialog("You should consider backing up your data before resetting.", isPresented: $showResetConfirmation3, titleVisibility: .visible) {
                                Button("Proceed", role: .destructive) {
                                    clearContext()
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                        
                        // MARK: Misc
                        VStack(spacing: 5) {
                            Link("Website",
                                 destination: URL(string: "https://sculpty.app")!)
                            
                            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                                Text("Sculpty Version \(version) Build \(build)")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                    }
                }
                .scrollClipDisabled()
                .padding()
            }
            .toolbarBackground(ColorManager.background)
            .toolbarBackground(.visible, for: .navigationBar)
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
    }
    
    private func shareBackup() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(ExportData(workouts: workouts, exercises: exercises, workoutLogs: workoutLogs, caloriesLogs: caloriesLogs))
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SculptyBackup.json")
            
            try data.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            
        } catch {
            print("Error creating backup file: \(error.localizedDescription)")
        }
    }
    
    
    private func getWorkoutLogsCSV() -> String {
        var csv = "Date,Time,Workout,Exercise,Muscle Group,Set Type,Reps/Time,Weight/Distance,Skipped\n"

        for workoutLog in workoutLogs {
            for exerciseLog in workoutLog.exerciseLogs {
                for setLog in exerciseLog.setLogs {
                    csv += "\"\(formatDate(workoutLog.end))\",\"\(formatTime(workoutLog.end))\",\"\(workoutLog.workout.name)\",\"\(exerciseLog.exercise.exercise?.name ?? "N/A")\",\"\(setLog.reps)\(setLog.measurement == "x" ? " reps" : setLog.measurement)\",\"\(setLog.weight)\",\"\(setLog.skipped ? "Skipped" : "")\",\"\n"
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
            print("Error writing CSV file: \(error)")
        }
    }
    
    
    private func clearContext() {
        do {
            context.rollback()
            
            let workoutLogs = try context.fetch(FetchDescriptor<WorkoutLog>())
            for log in workoutLogs {
                context.delete(log)
            }
            
            let workoutExercises = try context.fetch(FetchDescriptor<WorkoutExercise>())
            for exercise in workoutExercises {
                context.delete(exercise)
            }
            
            let workouts = try context.fetch(FetchDescriptor<Workout>())
            for workout in workouts {
                context.delete(workout)
            }
            
            let exercises = try context.fetch(FetchDescriptor<Exercise>())
            for exercise in exercises {
                context.delete(exercise)
            }
            
            let caloriesLogs = try context.fetch(FetchDescriptor<CaloriesLog>())
            for log in caloriesLogs {
                context.delete(log)
            }
            
            try context.save()
            
            withAnimation {
                UserDefaults.standard.resetUser()
            }
        } catch {
            print("Failed to clear context: \(error)")
        }
    }
}

#Preview {
    Options()
}
