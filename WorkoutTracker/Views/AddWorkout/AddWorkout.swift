//
//  AddWorkout.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData

struct AddWorkout: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: WorkoutViewModel = WorkoutViewModel(workout: Workout(name: "", notes: ""))
    
    @State private var titleAlert: Bool = false
    @State private var exercisesAlert: Bool = false
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
     
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Workout Name", text: $viewModel.workoutName)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                    .focused($isNameFocused)
                
                List {
                    ForEach(viewModel.exercises.sorted { $0.index < $1.index }, id: \.self) { exercise in
                        let index = viewModel.exercises.firstIndex(of: exercise)!
                        HStack {
                            Text(exercise.exercise?.name ?? "Select Exercise")
                            NavigationLink(destination: ExerciseInfo(workout: viewModel.workout, exercise: exercise.exercise ?? nil, workoutExercise: $viewModel.exercises[index])) {
                            }
                        }
                        .swipeActions {
                            Button("Delete") {
                                viewModel.removeExercise(at: index)
                            }
                            .tint(.red)
                        }
                    }
                    .onMove { from, to in
                        var reordered = viewModel.exercises
                        
                        reordered.move(fromOffsets: from, toOffset: to)
                        
                        for (newIndex, exercise) in reordered.enumerated() {
                            if exercise.index != newIndex {
                                exercise.index = newIndex
                            }
                        }
                        
                        viewModel.exercises = reordered
                    }
                }
                .backgroundStyle(.clear)
                
                Button {
                    viewModel.addExercise()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Exercise")
                    }
                }
                
                
                TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($isNotesFocused)
                
                
                Button {
                    guard !viewModel.workoutName.isEmpty else {
                        titleAlert = true
                        return
                    }
                    
                    var blankCount = 0
                    for exercise in viewModel.exercises {
                        if exercise.exercise == nil {
                            viewModel.exercises.remove(at: viewModel.exercises.firstIndex(of: exercise)!)
                            blankCount += 1
                        }
                    }
                    
                    guard viewModel.exercises.count > 0 else {
                        for _ in 0..<blankCount {
                            viewModel.addExercise()
                        }
                        
                        exercisesAlert = true
                        return
                    }
                    
                    viewModel.workout.name = viewModel.workoutName
                    viewModel.workout.exercises = viewModel.exercises
                    
                    context.insert(viewModel.workout)
                    context.insert(WorkoutLog(workout: viewModel.workout))

                    try? context.save()
                    
                    dismiss()
                } label: {
                    HStack {
                        Text("Save")
                    }
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
                .alert(isPresented: $titleAlert) {
                    Alert(title: Text("Error"),
                          message: Text("Please name this workout."))
                }
                .alert(isPresented: $exercisesAlert) {
                    Alert(title: Text("Error"),
                          message: Text("Please add at least one exercise."))
                }
            }
            .padding()
            .navigationTitle("Add Workout")
            .toolbar {
                ToolbarItemGroup (placement: .keyboard) {
                    Spacer()
                    
                    Button {
                        isNameFocused = false
                        isNotesFocused = false
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    AddWorkout()
}
