//
//  Options.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/20/25.
//

import SwiftUI
import SwiftData

struct Options: View {
    @Environment(\.modelContext) var context
    
    @Query private var workouts: [Workout]
    @Query private var exercises: [Exercise]
    @Query private var workoutLogs: [WorkoutLog]
    
    @State private var showImportSheet: Bool = false
    @State private var showExportSheet: Bool = false
    
    @State private var importing: Bool = false
    @State private var exporting: Bool = false
    
    @State private var showResetConfirmation1: Bool = false
    @State private var showResetConfirmation2: Bool = false
    @State private var showResetConfirmation3: Bool = false
    
    @State private var showImportSuccessAlert: Bool = false
    @State private var showImportFailAlert: Bool = false
    @State private var showResetAlert: Bool = false
    
    @State private var workoutsSelected: Bool = true
    @State private var exercisesSelected: Bool = true
    @State private var workoutLogsSelected: Bool = true
    
    @State private var allowDuplicates: Bool = false
    
    @State private var showStats: Bool = true
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Options")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
            }
            .padding()
            
            Button {
                showImportSheet = true
            } label: {
                Text("Import Data")
            }
            .buttonStyle(.borderedProminent)
            .alert(isPresented: $showImportSuccessAlert) {
                Alert(title: Text("Success"),
                      message: Text("Your data has successfully been imported."))
            }
            .alert(isPresented: $showImportFailAlert) {
                Alert(title: Text("Error"),
                      message: Text("There was an error when importing your data. Please make sure that you are uploading the correct file. You may need to try again later or report an issue."))
            }
            .sheet(isPresented: $showImportSheet, onDismiss: {
                importing = false
            }) {
                VStack {
                    Text("Select what to import")
                    
                    Toggle(isOn: $workoutsSelected) {
                        Text("Workouts")
                    }
                    
                    Toggle(isOn: $exercisesSelected) {
                        Text("Exercises")
                    }
                    
                    Toggle(isOn: $workoutLogsSelected) {
                        Text("Logs")
                    }
                    
                    Divider()
                        .padding()
                    
                    Toggle(isOn: $allowDuplicates) {
                        Text("Allow Duplicates")
                    }
                    
                    Text("When \"Allow Duplicates\" is disabled, any existing data that overlaps with imported data will be overwritten. To determine if data overlaps, the names are compared.")
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button {
                        importing = true
                    } label: {
                        Text("Import")
                    }
                    .buttonStyle(.borderedProminent)
                    .fileImporter(
                        isPresented: $importing,
                        allowedContentTypes: [.json],
                        allowsMultipleSelection: false
                    ) { result in
                        print("result: \(result)")
                        
                        switch result {
                        case .success(let urls):
                            guard let url = urls.first else { return }
                            guard let importedData = try? Data(contentsOf: url) else { return }
                            let decoder = JSONDecoder()
                            let data = try? decoder.decode(ExportData.self, from: importedData)
                            
                            if workoutsSelected {
                                let existingWorkouts = try? context.fetch(FetchDescriptor<Workout>())
                                for workout in data!.workouts {
                                    if !allowDuplicates && existingWorkouts?.contains(where: { $0.name == workout.name}) ?? false {
                                        context.delete(existingWorkouts!.first(where: { $0.name == workout.name })!)
                                    }
                                    
                                    context.insert(Workout(name: workout.name, exercises: workout.exercises, notes: workout.notes))
                                    context.insert(WorkoutLog(workout: workout))
                                }
                            }

                            if exercisesSelected {
                                let existingExercises = try? context.fetch(FetchDescriptor<Exercise>())
                                for exercise in data!.exercises {
                                    if !allowDuplicates && existingExercises?.contains(where: { $0.name == exercise.name }) ?? false {
                                        context.delete(existingExercises!.first(where: { $0.name == exercise.name })!)
                                    }
                                    
                                    context.insert(Exercise(name: exercise.name, notes: exercise.notes, muscleGroup: exercise.muscleGroup ?? .other))
                                }
                            }

                            if workoutLogsSelected {
                                for log in data!.workoutLogs {
                                    context.insert(WorkoutLog(workout: log.workout, started: log.started, completed: log.completed, start: log.start, end: log.end, exerciseLogs: log.exerciseLogs))
                                }
                            }

                            do {
                                try context.save()
                                importing = false
                                showImportSuccessAlert = true
                            } catch {
                                print("Failed to save imported data: \(error.localizedDescription)")
                                showImportFailAlert = true
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                .padding()
                .padding(.top, 20)
                .presentationDetents([.fraction(0.42), .medium])
            }
            
            
            Button {
                showExportSheet = true
            } label: {
                Text("Export Data")
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $showExportSheet, onDismiss: {
                exporting = false
            }) {
                VStack {
                    Text("Select what to export")
                    
                    Toggle(isOn: $workoutsSelected) {
                        Text("Workouts")
                    }
                    
                    Toggle(isOn: $exercisesSelected) {
                        Text("Exercises")
                    }
                    
                    Toggle(isOn: $workoutLogsSelected) {
                        Text("Logs")
                    }
                    
                    Button {
                        exporting = true
                    } label: {
                        Text("Export")
                    }
                    .fileExporter(
                        isPresented: $exporting,
                        document: ExportData(workouts: workouts, exercises: exercises.filter { !defaultExercises.contains($0) }, workoutLogs: workoutLogs),
                        contentType: .json,
                        defaultFilename: "WorkoutTrackerData.json"
                    ) { result in
                        switch result {
                        case .success(_):
                            exporting = false
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                .padding()
                .padding(.top, 20)
                .presentationDetents([.fraction(0.26), .medium])
            }
            
            
            Button {
                showResetConfirmation1 = true
            } label: {
                Text("Reset Data")
            }
            .padding()
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
            .confirmationDialog("It is recommended that you export your data before proceeding.", isPresented: $showResetConfirmation3, titleVisibility: .visible) {
                Button("Export then reset", role: .destructive) {
                    exporting = true
                    clearContext()
                    showResetAlert = true
                }
                Button("Reset without exporting", role: .destructive) {
                    clearContext()
                    showResetAlert = true
                }
            }
            .alert(isPresented: $showResetAlert) {
                Alert(title: Text("Success"),
                      message: Text("Your data has successfully been reset. Please restart the app to ensure everything works properly."))
            }
            
            
            Spacer()
            
            
            Link("GitHub",
                 destination: URL(string: "https://github.com/SeanL128/WorkoutTracker/")!)
            
            Link("Report a bug",
                 destination: URL(string: "https://github.com/SeanL128/WorkoutTracker/issues/new")!)
            .padding(.vertical, 5)
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                Text("Workout Tracker Version \(version) Build \(build)")
                    .font(.caption)
            }
        }
        .padding()
    }
    
    private func clearContext() {
        do {
            try context.delete(model: Workout.self)
            try context.delete(model: Exercise.self)
            try context.delete(model: WorkoutLog.self)
            
            try context.save()
        } catch {
            print("Failed to clear context: \(error.localizedDescription)")
        }
    }
}

#Preview {
    Options()
}
