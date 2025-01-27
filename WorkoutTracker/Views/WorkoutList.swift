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
    
    @State private var exporting: Bool = false
    @State private var importing: Bool = false
    
    var onWorkoutSelected: (Workout, WorkoutLog) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Workouts")
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    Button {
                        importing = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
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
                            let workout = try? decoder.decode(Workout.self, from: importedData)
                            
                            context.insert(Workout(name: workout!.name, exercises: workout!.exercises, notes: workout!.notes))
                            context.insert(WorkoutLog(workout: workout!))

                            do {
                                try context.save()
                                importing = false
                            } catch {
                                print("Failed to save imported data: \(error.localizedDescription)")
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    
                    NavigationLink(destination: AddWorkout(index: (workouts.map { $0.index }.max() ?? -1) + 1)) {
                        Image(systemName: "plus")
                    }
                }
                .padding()
                
                List {
                    ForEach(workouts.sorted { $0.index < $1.index }) { workout in
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
                                exporting = true
                            }
                            .fileExporter(
                                isPresented: $exporting,
                                document: workout,
                                contentType: .json,
                                defaultFilename: "\(workout.name).json"
                            ) { result in
                                switch result {
                                case .success(_):
                                    exporting = false
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                            .tint(.blue)
                        }
                    }
                    .onMove { from, to in
                        var reordered = workouts
                        
                        reordered.move(fromOffsets: from, toOffset: to)
                        
                        for (newIndex, workout) in reordered.enumerated() {
                            if workout.index != newIndex {
                                workout.index = newIndex
                            }
                        }
                        
                        for workout in workouts {
                            context.delete(workout)
                        }
                        
                        for workout in reordered {
                            context.insert(workout)
                        }
                        
                        try? context.save()
                    }
                }
                .scrollContentBackground(.hidden)
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
        }
        .ignoresSafeArea(.keyboard)
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
