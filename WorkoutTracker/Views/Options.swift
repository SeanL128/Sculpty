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
    
    @State private var showImportConfirmation: Bool = false
    
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
                showImportConfirmation = true
            } label: {
                Text("Import Information")
            }
            .buttonStyle(.borderedProminent)
            .confirmationDialog("Importing data will delete all existing data.", isPresented: $showImportConfirmation, titleVisibility: .visible) {
                Button("Import", role: .destructive) {
                    showDocumentPicker()
                }
            }
            
            Button {
                exportData()
            } label: {
                Text("Export Information")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
    
    private func exportData() {
        do {
            let exportData = ExportData(workouts: workouts, exercises: exercises, workoutLogs: workoutLogs)
            
            // Step 1: Encode workouts to JSON
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(exportData)
            
            // Step 2: Write the data to a temporary file
            let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("WorkoutTrackerData.json")
            try data.write(to: temporaryURL)
            
            // Step 3: Share the file
            presentShareSheet(url: temporaryURL)
        } catch {
            print("Failed to export workouts: \(error.localizedDescription)")
        }
    }
    
    private func presentShareSheet(url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func showDocumentPicker() {
        let coordinator = DocumentPickerCoordinator { importedData in
            if let importedData = importedData {
                self.importData(data: importedData)
            }
        }
        coordinator.showDocumentPicker()
    }
    
    private func importData(data: ExportData) {
        for workout in data.workouts {
            context.insert(Workout(name: workout.name, exercises: workout.exercises, notes: workout.notes))
        }
        
        for exercise in data.exercises {
            context.insert(Exercise(name: exercise.name, notes: exercise.notes, muscleGroup: exercise.muscleGroup ?? .other))
        }
        
        for log in data.workoutLogs {
            context.insert(WorkoutLog(workout: log.workout, started: log.started, completed: log.completed, start: log.start, end: log.end, exerciseLogs: log.exerciseLogs))
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save imported data: \(error.localizedDescription)")
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

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
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
