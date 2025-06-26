//
//  UpsertWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/25/25.
//

import SwiftUI
import SwiftData

struct UpsertWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var workout: Workout?
    
    @State private var workoutName: String
    @State private var workoutNotes: String
    @State private var exercises: [WorkoutExercise]
    private var sortedExercises: [WorkoutExercise] { exercises.sorted { $0.index < $1.index } }
    
    @State private var confirmDelete: Bool = false
    @State private var stayOnPage: Bool = true
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    @State private var editing: Bool = false
    
    private var isValid: Bool {
        !workoutName.isEmpty && exercises.filter { $0.exercise != nil }.count > 0
    }
    
    @State private var originalSnapshot: String?
    
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
                
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Button {
                            let snapshot = getSnapshot()
                            
                            if originalSnapshot != snapshot {
                                Popup.show(content: {
                                    ConfirmationPopup(selection: $stayOnPage, promptText: "Unsaved Changes", resultText: "Are you sure you want to leave without saving?", cancelText: "Discard Changes", confirmText: "Stay on Page")
                                })
                            } else {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(.trailing, 6)
                                .font(Font.system(size: 22))
                        }
                        .textColor()
                        .onChange(of: stayOnPage) {
                            if !stayOnPage {
                                cleanExercises()
                                
                                dismiss()
                            }
                        }
                        
                        Text("\(workout == nil ? "ADD" : "EDIT") WORKOUT")
                            .headingText(size: 32)
                            .textColor()
                        
                        Spacer()
                        
                        if let workout = workout {
                            Button {
                                cleanExercises()
                                
                                copyWorkout()
                                
                                dismiss()
                            } label: {
                                Image(systemName: "document.on.document")
                                    .padding(.horizontal, 5)
                                    .font(Font.system(size: 20))
                            }
                            .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
                            .disabled(!isValid)
                            
                            Button {
                                Popup.show(content: {
                                    ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(workout.name)?", resultText: "This cannot be undone.", cancelText: "Cancel", confirmText: "Delete")
                                })
                            } label: {
                                Image(systemName: "trash")
                                    .padding(.horizontal, 5)
                                    .font(Font.system(size: 20))
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
                    }
                    .padding(.bottom)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Input(title: "Name", text: $workoutName, isFocused: _isNameFocused, autoCapitalization: .words)
                                .frame(maxWidth: 250)
                            
                            
                            if sortedExercises.count > 0 {
                                HStack(alignment: .center) {
                                    Spacer()
                                    
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            editing.toggle()
                                        }
                                    } label: {
                                        Image(systemName: "chevron.up.chevron.down")
                                            .padding(.horizontal, 8)
                                            .font(Font.system(size: 18))
                                    }
                                    .foregroundStyle(editing ? Color.accentColor : ColorManager.text)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
                                    if let index = exercises.firstIndex(of: exercise) {
                                        HStack(alignment: .center) {
                                            if editing {
                                                VStack(alignment: .center, spacing: 10) {
                                                    Button {
                                                        if let above = sortedExercises.last(where: { $0.index < exercise.index }) {
                                                            let index = exercise.index
                                                            exercise.index = above.index
                                                            above.index = index
                                                        }
                                                    } label: {
                                                        Image(systemName: "chevron.up")
                                                            .font(Font.system(size: 14))
                                                    }
                                                    .foregroundStyle(sortedExercises.last(where: { $0.index < exercise.index }) == nil ? ColorManager.secondary : ColorManager.text)
                                                    .disabled(sortedExercises.last(where: { $0.index < exercise.index }) == nil)
                                                    
                                                    Button {
                                                        if let below = sortedExercises.first(where: { $0.index > exercise.index }) {
                                                            let index = exercise.index
                                                            exercise.index = below.index
                                                            below.index = index
                                                        }
                                                    } label: {
                                                        Image(systemName: "chevron.down")
                                                            .font(Font.system(size: 14))
                                                    }
                                                    .foregroundStyle(sortedExercises.first(where: { $0.index > exercise.index }) == nil ? ColorManager.secondary : ColorManager.text)
                                                    .disabled(sortedExercises.first(where: { $0.index > exercise.index }) == nil)
                                                }
                                            }
                                            
                                            NavigationLink(destination: {
                                                ExerciseInfo(
                                                    workout: workout ?? Workout(name: workoutName, exercises: exercises, notes: workoutNotes),
                                                    exercise: exercise.exercise,
                                                    workoutExercise: exercise
                                                )
                                            }) {
                                                Text(exercise.exercise?.name ?? "Select Exercise")
                                                    .bodyText(size: 18, weight: .bold)
                                                    .multilineTextAlignment(.leading)
                                                    
                                                Image(systemName: "chevron.right")
                                                    .padding(.leading, -2)
                                                    .font(Font.system(size: 12, weight: .bold))
                                            }
                                            .textColor()
                                            
                                            Spacer()
                                            
                                            Button {
                                                exercises.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .padding(.horizontal, 8)
                                                    .font(Font.system(size: 16))
                                            }
                                            .textColor()
                                        }
                                    }
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: sortedExercises.map { $0.id })
                            
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
                                        .font(Font.system(size: 12, weight: .bold))
                                    
                                    Text("Add Exercise")
                                        .bodyText(size: 16, weight: .bold)
                                }
                            }
                            .textColor()
                            
                            
                            Spacer()
                                .frame(height: 5)
                            
                            
                            Input(title: "Notes", text: $workoutNotes, isFocused: _isNotesFocused, axis: .vertical)
                            
                            
                            Spacer()
                                .frame(height: 5)
                            
                            
                            Button {
                                save()
                            } label: {
                                Text("Save")
                                    .bodyText(size: 20, weight: .bold)
                            }
                            .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
                            .disabled(!isValid)
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                    .scrollIndicators(.hidden)
                    .scrollContentBackground(.hidden)
                }
                .padding()
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup (placement: .keyboard) {
                    Spacer()
                    
                    KeyboardDoneButton(focusStates: [_isNameFocused, _isNotesFocused])
                }
            }
            .onAppear() {
                if exercises.isEmpty {
                    exercises.append(WorkoutExercise(index: 0))
                }
                
                originalSnapshot = getSnapshot()
            }
        }
    }
    
    private func cleanExercises() {
        for exercise in exercises {
            if exercise.exercise == nil {
                context.delete(exercise)
                exercises.remove(at: exercises.firstIndex(of: exercise)!)
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
                debugLog(error.localizedDescription)
                
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
                debugLog(error.localizedDescription)
                
                return
            }
            
            let workoutCopy = Workout(index: index, name: "Copy of \(workoutName)", exercises: exercises, notes: workoutNotes)
            
            for exercise in workout.exercises {
                workoutCopy.exercises.append(exercise.copy())
            }
            
            context.insert(workoutCopy)
            
            do {
                try context.save()
            } catch {
                debugLog("Failed to save workout copy: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func getSnapshot() -> String {
        let replacements = [("##:", "[DELIM]"), ("exercise--", "[DELIM]")]
        
        
        var snapshot: String = "name:\(workoutName.sanitize(replacements))##:notes:\(workoutNotes.sanitize(replacements))##:"
        
        for exercise in sortedExercises {
            snapshot += "exercise--id:\(exercise.id.uuidString)##:index:\(exercise.index)##:exercise:\(exercise.exercise?.id.uuidString ?? "none")##:restTime:\(exercise.restTime)##:specNotes:\(exercise.specNotes.sanitize(replacements))##:tempo:\(exercise.tempo)##:"
            
            for set in exercise.sets {
                snapshot += "id:\(set.id.uuidString)##:index:\(set.index)##:unit:\(set.unit)##:type:\(set.type.rawValue)##:exerciseType:\(set.exerciseType.rawValue)##:reps:\(set.reps ?? -1)##:weight:\(set.weight ?? -1)##:rir:\(set.rir ?? "none")##:time:\(set.time ?? -1)##:distance:\(set.distance ?? -1)##:"
            }
        }
        
        return snapshot
    }
}
