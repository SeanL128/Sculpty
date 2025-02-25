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
    
    @State var workout: Workout
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    init() {
        _workout = State(initialValue: Workout(name: "", exercises: [], notes: ""))
        
        workout.exercises.removeAll()
        
        let nextIndex = (workout.exercises.map { $0.index }.max() ?? -1) + 1
        workout.exercises.append(WorkoutExercise(index: nextIndex))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    TextField("Workout Name", text: $workout.name)
                        .textInputAutocapitalization(.words)
                        .focused($isNameFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    List {
                        ForEach(workout.exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
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
                        .focused($isNotesFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    
                    Button {
                        guard !workout.name.isEmpty else {
                            alertMessage = "Please name this workout."
                            showAlert = true
                            
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
        }
    }
}

#Preview {
    AddWorkout()
}
