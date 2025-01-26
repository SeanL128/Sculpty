//
//  AddWorkout.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/25/25.
//

import SwiftUI
import SwiftData

struct EditWorkout: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @Query var workouts: [Workout]
    
    @State var workout: Workout
    
    @State private var titleAlert: Bool = false
    @State private var exercisesAlert: Bool = false
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    var isAnyFieldFocused: Bool {
        isNameFocused || isNotesFocused
    }
    
    init(workout: Workout) {
        self._workout = State(initialValue: workout)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Workout Name", text: $workout.name)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                    .focused($isNameFocused)
                
                List {
                    ForEach(workout.exercises.sorted { $0.index < $1.index }, id: \.self) { exercise in
                        let index = workout.exercises.firstIndex(of: exercise)!
                        HStack {
                            Text(exercise.exercise?.name ?? "Select Exercise")
                            NavigationLink(destination: ExerciseInfo(workout: workout, exercise: exercise.exercise ?? nil, workoutExercise: $workout.exercises[index])) {
                            }
                        }
                        .swipeActions {
                            Button("Delete") {
                                workout.exercises.remove(at: index)
                            }
                            .tint(.red)
                        }
                    }
                    .onMove { from, to in
                        var reordered = workout.exercises
                        
                        reordered.move(fromOffsets: from, toOffset: to)
                        
                        for (newIndex, exercise) in reordered.enumerated() {
                            if exercise.index != newIndex {
                                exercise.index = newIndex
                            }
                        }
                        
                        workout.exercises = reordered
                    }
                }
                .scrollContentBackground(.hidden)
                
                Button {
                    let nextIndex = (workout.exercises.map { $0.index }.max() ?? -1) + 1
                    workout.exercises.append(WorkoutExercise(index: nextIndex))
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Exercise")
                    }
                }
                
                
                TextField("Notes", text: $workout.notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($isNotesFocused)
                
                
                Button {
                    guard !workout.name.isEmpty else {
                        titleAlert = true
                        return
                    }
                    
                    var blanks: [Int] = []
                    for exercise in workout.exercises {
                        if exercise.exercise == nil {
                            blanks.append(exercise.index)
                            workout.exercises.remove(at: workout.exercises.firstIndex(of: exercise)!)
                        }
                    }
                    
                    guard workout.exercises.count > 0 else {
                        for index in blanks {
                            workout.exercises.append(WorkoutExercise(index: index))
                        }
                        
                        exercisesAlert = true
                        return
                    }
                    
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
                    .disabled(!isAnyFieldFocused)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    EditWorkout(workout: Workout())
}
