//
//  WorkoutList.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/18/25.
//
import SwiftUI
import SwiftData

struct WorkoutList2: View {
    @Environment(\.modelContext) var context
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 }, sort: \.index) private var workouts: [Workout]
    @Query private var workoutLogs: [WorkoutLog]
    
    @State var workoutToDelete: Workout? = nil
    
    @State private var exporting: Bool = false
    @State private var importing: Bool = false
    
    @State private var showImportFailAlert: Bool = false
    
    var onWorkoutSelected: (Workout, WorkoutLog) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack {
                        Text("Workouts")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        Button {
                            importing = true
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                        .padding(.leading, 10)
                        .alert(isPresented: $showImportFailAlert) {
                            Alert(title: Text("Error"),
                                  message: Text("There was an error when importing this workout. Please make sure that you are selecting the correct file. You may need to try again later or report an issue."))
                        }
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
                                
                                guard let workout = try? decoder.decode(Workout.self, from: importedData) else {
                                    showImportFailAlert = true
                                    return
                                }
                                
                                DispatchQueue.main.async {
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

                                    do {
                                        try context.save()
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
                        
                        NavigationLink(destination: ExerciseList()) {
                            Image(systemName: "dumbbell")
                        }
                        .padding(.horizontal, 10)
                        
                        NavigationLink(destination: AddWorkout()) {
                            Image(systemName: "plus")
                        }
                        .padding(.trailing, 10)
                    }
                    .padding()
                    
                    List {
                        Section {
                            Button {
                                // action
                            } label: {
                                Text("Rest")
                            }
                            .foregroundStyle(ColorManager.text)
                        }
                        
                        Section {
                            ForEach(workouts) { workout in
                                HStack {
                                    if let todayLog = workoutLogs.first(where: { log in
                                        log.workout.id == workout.id &&
                                        Calendar.current.isDate(log.start, inSameDayAs: Date())
                                    }) {
                                        var backgroundColor: Color {
                                            if todayLog.completed {
                                                return Color.accentColor
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
                                                    Text(formatDate(previousLog.start))
                                                        .opacity(0.5)
                                                }
                                                
                                                Image(systemName: "chevron.right")
                                            }
                                            .foregroundStyle(ColorManager.text)
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
                                        workoutToDelete = workout
                                    }
                                    .tint(.red)
                                }
                                .swipeActions(edge: .leading) {
                                    Button("Copy") {
                                        copyWorkout(workout: workout)
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
                    }
                    .scrollContentBackground(.hidden)
                    .confirmationDialog("Delete \(workoutToDelete?.name ?? "workout")? This will also delete all related logs.", isPresented: Binding(
                        get: { workoutToDelete != nil },
                        set: { if !$0 { workoutToDelete = nil } }
                    ), titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            if let workout = workoutToDelete {
                                for log in (workoutLogs.filter { $0.workout == workout }) {
                                    context.delete(log)
                                }
                                
                                context.delete(workout)
                                try? context.save()
                                
                                workoutToDelete = nil
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private func copyWorkout(workout: Workout) {
        let workoutCopy = Workout(index: (workouts.map { $0.index }.max() ?? -1) + 1, name: "Copy of \(workout.name)", exercises: [], notes: workout.notes)
        
        for exercise in workout.exercises {
            let exerciseCopy = WorkoutExercise(index: exercise.index, exercise: exercise.exercise, sets: [], restTime: exercise.restTime, specNotes: exercise.specNotes, tempo: exercise.tempo)
            
            for exerciseSet in exercise.sets {
                exerciseCopy.sets.append(ExerciseSet(index: exerciseSet.index, reps: exerciseSet.reps, weight: exerciseSet.weight, measurement: exerciseSet.measurement, type: exerciseSet.type, rir: exerciseSet.rir))
            }
            
            workoutCopy.exercises.append(exerciseCopy)
        }
        
        context.insert(workoutCopy)
        context.insert(WorkoutLog(workout: workoutCopy))
        
        do {
            try context.save()
        } catch {
            print("Failed to save workout copy: \(error.localizedDescription)")
        }
    }
}

#Preview {
    @Previewable @State var showViewWorkout: Bool = false
    @Previewable @State var selectedWorkout: Workout?
    @Previewable @State var selectedLog: WorkoutLog?
    
    WorkoutList2 { workout, log in
        selectedWorkout = workout
        selectedLog = log
        showViewWorkout = true
    }
}
