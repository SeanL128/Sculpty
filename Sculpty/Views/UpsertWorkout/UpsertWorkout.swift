//
//  UpsertWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/25/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct UpsertWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var workout: Workout?
    
    @State private var workoutName: String
    @State private var workoutNotes: String
    @State private var exercises: [WorkoutExercise]
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var confirmDelete: Bool = false
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    private var isValid: Bool {
        !workoutName.isEmpty && exercises.filter { $0.exercise != nil }.count > 0
    }
    
    init() {
        workoutName = ""
        workoutNotes = ""
        exercises = []
    }
    
    init (workout: Workout) {
        self.workout = workout
        
        workoutName = workout.name
        workoutNotes = workout.notes
        exercises = workout.exercises
    }
    
    var body: some View {
        ContainerView(title: "\(workout != nil ? "Edit" : "Add") Workout", spacing: 20, trailingItems: {
            if let workout = workout {
                Button {
                    copyWorkout()
                    
                    dismiss()
                } label: {
                    Image(systemName: "document.on.document")
                        .font(.title2)
                        .padding(.horizontal, 3)
                }
                .textColor()
                
                Button {
                    Task {
                        await ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(workout.name)?", resultText: "This will also delete all related logs.", cancelText: "Cancel", confirmText: "Delete").present()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                        .padding(.horizontal, 3)
                }
                .textColor()
                .onChange(of: confirmDelete) {
                    if confirmDelete {
                        workout.hide()
                        
                        try? context.save()
                        
                        dismiss()
                    }
                }
            }
        }) {
            VStack(alignment: .leading) {
                Text("Name")
                    .bodyText(size: 12)
                    .textColor()
                
                TextField("", text: $workoutName)
                    .textInputAutocapitalization(.words)
                    .focused($isNameFocused)
                    .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isNameFocused }, set: { isNameFocused = $0 }), text: $workoutName))
            }
            
            VStack(alignment: .leading) {
                Text("Notes")
                    .bodyText(size: 12)
                    .textColor()
                
                TextField("", text: $workoutNotes, axis: .vertical)
                    .focused($isNotesFocused)
                    .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isNotesFocused }, set: { isNotesFocused = $0 }), text: $workoutNotes))
            }
            
            
            Spacer()
                .frame(height: 5)
            
            
            ForEach(exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
                if let index = exercises.firstIndex(of: exercise) {
                    HStack(alignment: .center) {
                        NavigationLink(destination: {
                            ExerciseInfo(
                                workout: workout ?? Workout(name: workoutName, exercises: exercises, notes: workoutNotes),
                                exercise: exercise.exercise,
                                workoutExercise: exercise
                            )
                        }) {
                            if let name = exercise.exercise?.name {
                                Text(name)
                                    .bodyText(size: 16)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("Select Exercise")
                                    .bodyText(size: 16)
                                    .multilineTextAlignment(.leading)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                            }
                        }
                        .textColor()
                        
                        if exercise.exercise != nil {
                            Spacer()
                            
                            Button {
                                exercises.remove(at: index)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption)
                            }
                            .textColor()
                        }
                    }
                }
            }
            
            Button {
                let nextIndex = (exercises.map { $0.index }.max() ?? -1) + 1
                let newExercise = WorkoutExercise(index: nextIndex)
                
                if let existingWorkout = workout {
                    newExercise.workout = existingWorkout
                }
                
                context.insert(newExercise)
                exercises.append(newExercise)
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus")
                    
                    Text("Add Exercise")
                }
            }
            
            
            Spacer()
                .frame(height: 5)
            
            
            Button {
                save()
            } label: {
                Text("Save")
                    .bodyText(size: 18)
            }
            .disabled(!isValid)
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
        }
        .onAppear() {
            // Add initial exercise if the list is empty
            if exercises.isEmpty {
                exercises.append(WorkoutExercise(index: 0))
            }
        }
    }
    
    private func save() {
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
            workout.notes = workoutNotes
            
            let existingIds = Set(workout.exercises.map { $0.id })
            let updatedIds = Set(exercises.map { $0.id })
            
            workout.exercises.removeAll(where: { !updatedIds.contains($0.id) })
            
            for exercise in exercises {
                if !existingIds.contains(exercise.id) {
                    exercise.workout = workout
                    context.insert(exercise)
                    workout.exercises.append(exercise)
                }
                
                if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
                    exercise.index = index
                }
            }
        } else {
            var index = -1
            
            do {
                index = (try context.fetch(FetchDescriptor<Workout>()).map { $0.index }.max() ?? -1) + 1
            } catch {
                print(error.localizedDescription)
                
                return
            }
            
            let workout = Workout(name: workoutName, exercises: exercisesToSave, notes: workoutNotes)
            workout.index = index
            
            context.insert(workout)
        }

        try? context.save()
        
        dismiss()
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
                workoutCopy.exercises.append(exercise.copy())
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
