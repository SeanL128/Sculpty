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
    
    @State private var showExportSheet: Bool = false
    @State private var showImportSheet: Bool = false
    
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
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Options")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
            }
            .padding()
            
            Link("GitHub",
                 destination: URL(string: "https://github.com/SeanL128/WorkoutTracker/")!)
            .padding(.top)
            
            Link("Report a bug",
                 destination: URL(string: "https://github.com/SeanL128/WorkoutTracker/issues/new")!)
            .padding(.top, 5)
            
            
            Spacer()
            
            
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
            .sheet(isPresented: $showImportSheet) {
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
                        showDocumentPicker()
                    } label: {
                        Text("Import")
                    }
                    .padding(.top, 10)
                }
                .padding()
                .padding(.top, 20)
                .presentationDetents([.fraction(0.41), .medium])
            }
            
            
            Button {
                showExportSheet = true
            } label: {
                Text("Export Data")
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $showExportSheet) {
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
                        exportData()
                    } label: {
                        Text("Export")
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
                    exportData()
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
        }
    }
    
    private func exportData() {
        do {
            let exportData = ExportData(workouts: workoutsSelected ? workouts : [], exercises: exercisesSelected ? exercises : [], workoutLogs: workoutLogsSelected ? workoutLogs : [])
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(exportData)
            
            let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("WorkoutTrackerData.json")
            try data.write(to: temporaryURL)
            
            presentShareSheet(url: temporaryURL)
        } catch {
            print("Failed to export workouts: \(error.localizedDescription)")
        }
    }
    
    private func showDocumentPicker() {
        let coordinator = ExportDataDocumentPickerCoordinator { importedData in
            if let importedData = importedData {
                self.importData(data: importedData)
            }
        }
        coordinator.showDocumentPicker()
    }
    
    private func importData(data: ExportData) {
        if workoutsSelected {
            let existingWorkouts = try? context.fetch(FetchDescriptor<Workout>())
            for workout in data.workouts {
                if let result = (existingWorkouts?.filter { $0.name == workout.name }), !result.isEmpty {
                    for existingWorkout in result {
                        context.delete(existingWorkout)
                    }
                }
                
                context.insert(Workout(name: workout.name, exercises: workout.exercises, notes: workout.notes))
            }
        }
        
        if exercisesSelected {
            let existingExercises = try? context.fetch(FetchDescriptor<Exercise>())
            for exercise in data.exercises {
                if let result = (existingExercises?.filter { $0.name == exercise.name }), !result.isEmpty {
                    for existingExercise in result {
                        context.delete(existingExercise)
                    }
                }
                
                context.insert(Exercise(name: exercise.name, notes: exercise.notes, muscleGroup: exercise.muscleGroup ?? .other))
            }
        }
        
        if workoutLogsSelected {
            for log in data.workoutLogs {
                context.insert(WorkoutLog(workout: log.workout, started: log.started, completed: log.completed, start: log.start, end: log.end, exerciseLogs: log.exerciseLogs))
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
    
    private func clearContext() {
        do {
            // Fetch all entities for Workout
            let workoutsToDelete = try context.fetch(FetchDescriptor<Workout>())
            for workout in workoutsToDelete {
                context.delete(workout)
            }
            
            // Fetch all entities for Exercise
            let exercisesToDelete = try context.fetch(FetchDescriptor<Exercise>())
            for exercise in exercisesToDelete {
                context.delete(exercise)
            }
            
            // Fetch all entities for WorkoutLog
            let logsToDelete = try context.fetch(FetchDescriptor<WorkoutLog>())
            for log in logsToDelete {
                context.delete(log)
            }
            
            // Save changes to commit deletions
            try context.save()
        } catch {
            print("Failed to clear context: \(error.localizedDescription)")
        }
    }
}

class ExportDataDocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    private let onImport: (ExportData?) -> Void
    
    init(onImport: @escaping (ExportData?) -> Void) {
        self.onImport = onImport
    }
    
    func showDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        documentPicker.delegate = self
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            onImport(nil)
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let importedData = try decoder.decode(ExportData.self, from: data)
            onImport(importedData)
        } catch {
            print("Failed to import workouts: \(error.localizedDescription)")
            onImport(nil)
        }
    }
}

#Preview {
    Options()
}
