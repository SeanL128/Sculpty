//
//  AddWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/25/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct AddWorkout: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    private var workout: Workout?
    
    @State private var workoutName: String
    @State private var workoutNotes: String
    @State private var exercises: [WorkoutExercise]
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var confirmDelete: Bool = false
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    init() {
        self.workoutName = ""
        self.workoutNotes = ""
        self.exercises = []
    }
    
    init (workout: Workout) {
        self.workout = workout
        
        self.workoutName = workout.name
        self.workoutNotes = workout.notes
        self.exercises = workout.exercises
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    TextField("WORKOUT NAME", text: $workoutName)
                        .textInputAutocapitalization(.words)
                        .focused($isNameFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    List {
                        ForEach(exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
                            let index = exercises.firstIndex(of: exercise)!
                            HStack {
                                Text(exercise.exercise?.name ?? "SELECT EXERCISE")
                                NavigationLink(destination: ExerciseInfo(workout: Workout(name: workoutName, exercises: exercises, notes: workoutNotes), exercise: exercise.exercise ?? nil, workoutExercise: $exercises[index])) {
                                }
                            }
                            .swipeActions {
                                Button("DELETE") {
                                    exercises.remove(at: index)
                                }
                                .tint(.red)
                            }
                        }
                        .onMove { from, to in
                            var reordered = exercises
                            
                            reordered.move(fromOffsets: from, toOffset: to)
                            
                            for (newIndex, exercise) in reordered.enumerated() {
                                if exercise.index != newIndex {
                                    exercise.index = newIndex
                                }
                            }
                            
                            exercises = reordered
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    Button {
                        let nextIndex = (exercises.map { $0.index }.max() ?? -1) + 1
                        exercises.append(WorkoutExercise(index: nextIndex))
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("ADD EXERCISE")
                        }
                    }
                    
                    
                    TextField("NOTES", text: $workoutNotes, axis: .vertical)
                        .focused($isNotesFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    
                    Button {
                        guard !workoutName.isEmpty else {
                            alertMessage = "PLEASE NAME THIS WORKOUT."
                            showAlert = true
                            
                            return
                        }
                        
                        var blanks: [Int] = []
                        var exercisesToSave = exercises
                        
                        for exercise in exercisesToSave {
                            if exercise.exercise == nil {
                                blanks.append(exercise.index)
                                exercisesToSave.remove(at: exercisesToSave.firstIndex(of: exercise)!)
                            }
                        }
                        
                        guard exercisesToSave.count > 0 else {
                            for index in blanks {
                                exercises.append(WorkoutExercise(index: index))
                            }
                            
                            alertMessage = "PLEASE ADD AT LEAST ONE EXERCISE."
                            showAlert = true
                            
                            return
                        }
                        
                        if let workout = workout {
                            workout.name = workoutName
                            workout.exercises = exercises
                            workout.notes = workoutNotes
                        } else {
                            var index = -1
                            
                            do {
                                index = (try context.fetch(FetchDescriptor<Workout>()).map { $0.index }.max() ?? -1) + 1
                            } catch {
                                print(error.localizedDescription)
                                
                                return
                            }
                            
                            // Create the actual workout at save time
                            let workout = Workout(name: workoutName, exercises: exercisesToSave, notes: workoutNotes)
                            workout.index = index
                            
                            context.insert(workout)
                        }

                        try? context.save()
                        
                        dismiss()
                    } label: {
                        HStack {
                            Text("SAVE")
                        }
                    }
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .navigationTitle("\(workout != nil ? "EDIT" : "ADD") WORKOUT")
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("ERROR"), message: Text(alertMessage))
                }
                .confirmationDialog("Delete \(workoutName)? This will also delete all related logs.", isPresented: $confirmDelete, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        if let workout = workout {
                            do {
                                for log in ((try context.fetch(FetchDescriptor<WorkoutLog>())).filter { $0.workout == workout }) {
                                    context.delete(log)
                                }
                                
                                context.delete(workout)
                                try? context.save()
                                
                                dismiss()
                            } catch {
                                print (error.localizedDescription)
                                
                                return
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup (placement: .keyboard) {
                        Spacer()
                        
                        Button {
                            isNameFocused = false
                            isNotesFocused = false
                        } label: {
                            Text("DONE")
                        }
                        .disabled(!(isNameFocused || isNotesFocused))
                    }
                    
                    if workout != nil {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Spacer()
                            
                            Button {
                                copyWorkout()
                                
                                dismiss()
                            } label: {
                                Image(systemName: "document.on.document")
                                    .font(.footnote)
                            }
                            
                            Button {
                                confirmDelete = true
                            } label: {
                                Image(systemName: "trash")
                                    .padding(.horizontal, 5)
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }
            .onAppear {
                // Add initial exercise if the list is empty
                if exercises.isEmpty {
                    exercises.append(WorkoutExercise(index: 0))
                }
            }
            .onDisappear {
                // Clean up
                exercises.removeAll { $0.exercise == nil }
            }
        }
    }
    
    private func copyWorkout() {
        if let workout = workout {
            var index = -1
            
            do {
                index = (try context.fetch(FetchDescriptor<Workout>()).map { $0.index }.max() ?? -1) + 1
            } catch {
                print(error.localizedDescription)
                
                return
            }
            
            let workoutCopy = Workout(index: index, name: "Copy of \(workout.name)", exercises: [], notes: workout.notes)
            
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
}
