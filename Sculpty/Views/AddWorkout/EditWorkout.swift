//
//  EditWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/25/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct EditWorkout: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @Query private var workoutLogs: [WorkoutLog]
    
    @Bindable var workout: Workout
    
    @State private var workoutName: String
    @State private var workoutNotes: String
    @State private var exercises: [WorkoutExercise]
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var deleteWorkout: Bool = false
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    init(workout: Workout) {
        self.workout = workout
        // Initialize state with the workout's current values
        _workoutName = State(initialValue: workout.name)
        _workoutNotes = State(initialValue: workout.notes)
        _exercises = State(initialValue: workout.exercises)
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
                                Text(exercise.exercise?.name ?? "Select Exercise")
                                NavigationLink(destination: ExerciseInfo(workout: workout, exercise: exercise.exercise ?? nil, workoutExercise: $exercises[index])) {
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
                        
                        var validExercises = exercises
                        validExercises.removeAll { $0.exercise == nil }
                        
                        guard !validExercises.isEmpty else {
                            alertMessage = "Please add at least one exercise."
                            showAlert = true
                            return
                        }
                        
                        // Update the workout with the edited values
                        workout.name = workoutName
                        workout.notes = workoutNotes
                        
                        // Update exercises
                        workout.exercises = validExercises
                        
                        // Save changes
                        try? context.save()
                        
                        dismiss()
                    } label: {
                        HStack {
                            Text("Save Changes")
                        }
                    }
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .navigationTitle("Edit Workout")
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage))
                }
                .confirmationDialog("Delete \(workoutName)? This will also delete all related logs.", isPresented: $deleteWorkout, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        for log in (workoutLogs.filter { $0.workout == workout }) {
                            context.delete(log)
                        }
                        
                        context.delete(workout)
                        try? context.save()
                        
                        deleteWorkout = false
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Spacer()
                        
                        Button {
                            deleteWorkout = true
                        } label: {
                            Image(systemName: "document.on.document")
                                .padding(.horizontal, 5)
                        }
                    }
                    
                    ToolbarItemGroup(placement: .keyboard) {
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
        }
    }
}
