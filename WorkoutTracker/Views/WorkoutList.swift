//
//  WorkoutList.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/18/25.
//
import SwiftUI
import SwiftData

struct WorkoutList: View {
    @Environment(\.modelContext) var context
    
    @Query var workouts: [Workout]
    @Query var workoutLogs: [WorkoutLog]
    
    @State var delete: (Bool, Workout) = (false, Workout())
    
    var onWorkoutSelected: (Workout, WorkoutLog) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Workouts")
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    Button {
                        showDocumentPicker()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    
                    NavigationLink(destination: AddWorkout()) {
                        Image(systemName: "plus")
                    }
                }
                .padding()
                
                List {
                    ForEach(workouts) { workout in
                        HStack {
                            if let todayLog = workoutLogs.first(where: { log in
                                log.workout.id == workout.id &&
                                Calendar.current.isDate(Date(timeIntervalSince1970: log.start), inSameDayAs: Date())
                            }) {
                                var backgroundColor: Color {
                                    if todayLog.completed {
                                        return .accent
                                    }
                                    
                                    return Color(UIColor.systemBackground)
                                }
                                
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        onWorkoutSelected(workout, todayLog)
                                    }
                                } label: {
                                    HStack {
                                        Text(workout.name)
                                        
                                        Spacer()
                                        
                                        if let previousLog = workoutLogs.sorted(by: { $0.start > $1.start }).first(where: { log in
                                            log.completed &&
                                            log.workout.id == workout.id
                                        }) {
                                            Text(formatDate(Date(timeIntervalSince1970: previousLog.start)))
                                                .opacity(0.5)
                                        }
                                        
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundStyle(textColor)
                                    .listRowBackground(backgroundColor)
                                }
                            } else {
                                HStack {
                                    Text(workout.name)
                                    Text("(Error - please restart app or alert developer)")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .swipeActions {
                            Button("Delete") {
                                delete.0 = true
                                delete.1 = workout
                            }
                            .tint(.red)
                            
                            Button("Share") {
                                exportData(workout: workout)
                            }
                            .tint(.blue)
                        }
                    }
                    .onMove { from, to in
                        var copy = workouts
                        copy.move(fromOffsets: from, toOffset: to)
                        
                        for workout in workouts {
                            context.delete(workout)
                        }
                        
                        for workout in copy {
                            context.insert(workout)
                        }
                        
                        try? context.save()
                    }
                }
                .backgroundStyle(.clear)
                .confirmationDialog("Are you sure?", isPresented: $delete.0) {
                    Button("Delete \(delete.1.name)?", role: .destructive) {
                        context.delete(delete.1)
                        try? context.save()
                        
                        delete.0 = false
                        delete.1 = Workout()
                    }
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func exportData(workout: Workout) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(workout)
            
            let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(workout.name).json")
            try data.write(to: temporaryURL)
            
            presentShareSheet(url: temporaryURL)
        } catch {
            print("Failed to export \(workout.name): \(error.localizedDescription)")
        }
    }
    
    private func showDocumentPicker() {
        let coordinator = WorkoutDocumentPickerCoordinator { importedData in
            if let importedData = importedData {
                self.importData(workout: importedData)
            }
        }
        coordinator.showDocumentPicker()
    }
    
    private func importData(workout: Workout) {
        context.insert(Workout(name: workout.name, exercises: workout.exercises, notes: workout.notes))
        
        do {
            try context.save()
        } catch {
            print("Failed to save imported \(workout.name): \(error.localizedDescription)")
        }
    }
}

class WorkoutDocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    private let onImport: (Workout?) -> Void
    
    init(onImport: @escaping (Workout?) -> Void) {
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
            let importedData = try decoder.decode(Workout.self, from: data)
            onImport(importedData)
        } catch {
            print("Failed to import workouts: \(error.localizedDescription)")
            onImport(nil)
        }
    }
}

#Preview {
    @Previewable @State var showViewWorkout: Bool = false
    @Previewable @State var selectedWorkout: Workout?
    @Previewable @State var selectedLog: WorkoutLog?
    
    WorkoutList { workout, log in
        selectedWorkout = workout
        selectedLog = log
        showViewWorkout = true
    }
}
