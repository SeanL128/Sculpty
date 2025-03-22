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
    
    @State private var workoutName: String = ""
    @State private var workoutNotes: String = ""
    @State private var exercises: [WorkoutExercise] = []
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
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
                                Text(exercise.exercise?.name ?? "Select Exercise")
                                NavigationLink(destination: ExerciseInfo(workout: Workout(name: workoutName, exercises: exercises, notes: workoutNotes), exercise: exercise.exercise ?? nil, workoutExercise: $exercises[index])) {
                                }
                            }
                            .swipeActions {
                                Button("Delete") {
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
                            Text("Add Exercise")
                        }
                    }
                    
                    
                    TextField("Notes", text: $workoutNotes, axis: .vertical)
                        .focused($isNotesFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    
                    Button {
                        guard !workoutName.isEmpty else {
                            alertMessage = "Please name this workout."
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
                            
                            alertMessage = "Please add at least one exercise."
                            showAlert = true
                            
                            return
                        }
                        
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
                        context.insert(WorkoutLog(workout: workout))

                        try? context.save()
                        
                        dismiss()
                    } label: {
                        HStack {
                            Text("Save")
                        }
                    }
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .navigationTitle("Add Workout")
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage))
                }
                .toolbar {
                    ToolbarItemGroup (placement: .keyboard) {
                        Spacer()
                        
                        Button {
                            isNameFocused = false
                            isNotesFocused = false
                        } label: {
                            Text("Done")
                        }
                        .disabled(!(isNameFocused || isNotesFocused))
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
}
