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
                            if let index = exercises.firstIndex(of: exercise) {
                                HStack {
                                    Text(exercise.exercise?.name ?? "SELECT EXERCISE")
                                    NavigationLink(destination: {
                                        ExerciseInfo(
                                            workout: workout ?? Workout(name: workoutName, exercises: exercises, notes: workoutNotes),
                                            exercise: exercise.exercise,
                                            workoutExercise: exercise
                                        )
                                    }) { }
                                }
                                .swipeActions {
                                    Button("DELETE") {
                                        exercises.remove(at: index)
                                    }
                                    .tint(.red)
                                }
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
                        let newExercise = WorkoutExercise(index: nextIndex)
                        
                        if let existingWorkout = workout {
                            newExercise.workout = existingWorkout
                        }
                        
                        context.insert(newExercise)
                        exercises.append(newExercise)
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
                                Task {
                                    await ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(workoutName)?", resultText: "This will also delete all related logs.", cancelText: "Cancel", confirmText: "Delete").present()
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .padding(.horizontal, 5)
                                    .font(.footnote)
                            }
                            .onChange(of: confirmDelete) {
                                if confirmDelete,
                                   let workout = workout {
                                    workout.hide()
                                    
                                    try? context.save()
                                    
                                    dismiss()
                                }
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

/*
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
     
     @State private var workout: Workout
     
     @State private var new: Bool
     
     @State private var confirmDelete: Bool = false
     
     @FocusState private var isNameFocused: Bool
     @FocusState private var isNotesFocused: Bool
     
     private var isValid: Bool {
         !workout.name.isEmpty && workout.exercises.filter { $0.exercise != nil }.count > 0
     }
     
     init (workout: Workout = Workout()) {
         self.workout = workout
         
         new = (workout.name == "")
     }
     
     var body: some View {
         ContainerView(title: "\(new ? "Add" : "Edit") Workout", spacing: 20, trailingItems: {
             if !new {
                 Button {
                     copyWorkout()
                     
                     dismiss()
                 } label: {
                     Image(systemName: "document.on.document")
                         .font(.title2)
                         .padding(.horizontal, 3)
                 }
                 
                 Button {
                     Task {
                         await ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(workout.name)?", resultText: "This will also delete all related logs.", cancelText: "Cancel", confirmText: "Delete").present()
                     }
                 } label: {
                     Image(systemName: "trash")
                         .font(.title2)
                         .padding(.horizontal, 3)
                 }
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
                 
                 TextField("", text: $workout.name)
                     .textInputAutocapitalization(.words)
                     .focused($isNameFocused)
                     .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isNameFocused }, set: { isNameFocused = $0 })))
             }
             
             VStack(alignment: .leading) {
                 Text("Notes")
                     .bodyText(size: 12)
                     .textColor()
                 
                 TextField("", text: $workout.notes, axis: .vertical)
                     .focused($isNotesFocused)
                     .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isNotesFocused }, set: { isNotesFocused = $0 })))
             }
             
             
             Spacer()
                 .frame(height: 5)
             
             
             ForEach(workout.exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
                 if let index = workout.exercises.firstIndex(of: exercise) {
                     HStack(alignment: .center) {
                         NavigationLink(destination: ExerciseInfo(workout: workout, exercise: exercise.exercise, workoutExercise: exercise)) {
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
                                 workout.exercises.remove(at: index)
                             } label: {
                                 Image(systemName: "xmark")
                                     .font(.caption2)
                             }
                             .textColor()
                         }
                     }
                 }
             }
             
             Button {
                 let nextIndex = (workout.exercises.map { $0.index }.max() ?? -1) + 1
                 let newExercise = WorkoutExercise(index: nextIndex)
                 newExercise.workout = workout
                 
                 context.insert(newExercise)
                 workout.exercises.append(newExercise)
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
         .onAppear {
             // Add initial exercise if the list is empty
             if workout.exercises.isEmpty {
                 workout.exercises.append(WorkoutExercise(index: 0))
             }
         }
     }
     
     private func save() {
         if new {
             var index = -1
             
             do {
                 index = (try context.fetch(FetchDescriptor<Workout>()).map { $0.index }.max() ?? -1) + 1
             } catch {
                 print(error.localizedDescription)
                 
                 return
             }
             
             workout.index = index
             
             context.insert(workout)
         }

         try? context.save()
         
         dismiss()
     }
     
     private func copyWorkout() {
         if !new {
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

 */
