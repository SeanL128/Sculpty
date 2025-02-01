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
    @Environment(\.dismiss) var dismiss
    
    @Query private var workouts: [Workout]
    @Query private var exercises: [Exercise]
    @Query private var workoutLogs: [WorkoutLog]
    
    @State private var showImportSheet: Bool = false
    
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
                      message: Text("Your data has successfully been imported.\n\nPlease note that there is a known issue with workout logs and they have not been imported."))
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
                    
                    // Will (hopefully) be re-enabled in a future update
//                    Toggle(isOn: $workoutLogsSelected) {
//                        Text("Logs")
//                    }
                    
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
                        switch result {
                        case .success(let urls):
                            guard let url = urls.first else { return }
                            
                            guard url.startAccessingSecurityScopedResource() else {
                                showImportFailAlert = true
                                return
                            }
                            
                            guard let importedData = try? Data(contentsOf: url) else {
                                showImportFailAlert = true
                                return
                            }
                            
                            url.stopAccessingSecurityScopedResource()
                            
                            let decoder = JSONDecoder()
                            
                            guard let data = try? decoder.decode(ExportData.self, from: importedData) else {
                                showImportFailAlert = true
                                return
                            }
                            
                            DispatchQueue.main.async {
                                let logs = (try? context.fetch(FetchDescriptor<WorkoutLog>())) ?? []
                                for log in logs {
                                    for exerciseLog in log.exerciseLogs {
                                        if exerciseLog.exercise.exercise == nil {
                                            log.exerciseLogs.remove(at: log.exerciseLogs.firstIndex(where: { $0 === exerciseLog })!)
                                        }
                                    }
                                }
                                
                                if exercisesSelected {
                                    let existingExercises = (try? context.fetch(FetchDescriptor<Exercise>())) ?? []
                                    for exercise in data.exercises {
                                        guard !exercise.name.isEmpty && exercise.muscleGroup != nil else { continue }
                                        if exercise.notes.isEmpty { exercise.notes = "" }
                                        
                                        if !allowDuplicates && existingExercises.contains(where: { $0.name == exercise.name }) {
                                            context.delete(existingExercises.first(where: { $0.name == exercise.name })!)
                                        }
                                        
                                        context.insert(Exercise(name: exercise.name, notes: exercise.notes, muscleGroup: exercise.muscleGroup ?? .other))
                                    }
                                }
                                
                                if workoutsSelected {
                                    let existingWorkouts = (try? context.fetch(FetchDescriptor<Workout>())) ?? []
                                    
                                    for workout in data.workouts {
                                        if !allowDuplicates && existingWorkouts.contains(where: { $0.name == workout.name}) {
                                            context.delete(existingWorkouts.first(where: { $0.name == workout.name })!)
                                        }
                                        
                                        var exercises: [WorkoutExercise] = []
                                        for workoutExercise in workout.exercises {
                                            let exercise: Exercise = workoutExercise.exercise!
                                            let existingExercise = try? context.fetch(FetchDescriptor<Exercise>()).first(where: { $0.name == exercise.name && $0.notes == exercise.notes && $0.muscleGroup == exercise.muscleGroup })
                                            
                                            if existingExercise != nil {
                                                workoutExercise.exercise = existingExercise!
                                            } else {
                                                let newExercise = Exercise(name: exercise.name, notes: exercise.notes, muscleGroup: exercise.muscleGroup ?? .other)
                                                workoutExercise.exercise = newExercise
                                                context.insert(newExercise)
                                            }
                                            
                                            exercises.append(workoutExercise)
                                        }
                                        
                                        let newWorkout = Workout(name: workout.name, exercises: [], notes: workout.notes)
                                        for workoutExercise in exercises {
                                            workoutExercise.workout = newWorkout
                                        }
                                        
                                        context.insert(newWorkout)
                                        do {
                                            try context.save()
                                        } catch {
                                            print("Failed to save workout: \(error.localizedDescription)")
                                        }
                                        
                                        newWorkout.exercises = exercises
                                        
                                        context.insert(WorkoutLog(workout: newWorkout))
                                    }
                                }

                                do {
                                    try context.save()
                                    showImportSuccessAlert = true
                                } catch {
                                    print("Failed to save imported data: \(error.localizedDescription)")
                                    showImportFailAlert = true
                                }
                            }
                            importing = false
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
                exporting = true
            } label: {
                Text("Export Data")
            }
            .buttonStyle(.borderedProminent)
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
            let workouts = try context.fetch(FetchDescriptor<Workout>())
            
            for workout in workouts {
                context.delete(workout)
            }
            
            
            let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
            
            for log in logs {
                context.delete(log)
            }
            
            
            let exercises = try context.fetch(FetchDescriptor<Exercise>())
            
            for exercise in exercises {
                context.delete(exercise)
            }
            
            
            try context.save()
        } catch {
            print("Failed to clear context: \(error)")
        }
    }
}

#Preview {
    Options()
}
