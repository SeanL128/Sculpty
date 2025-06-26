//
//  UpsertExercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData
import BRHSegmentedControl

struct UpsertExercise: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State var exercise: Exercise?
    
    @Binding var selectedExercise: Exercise?
    
    @State private var exerciseName: String
    @State private var exerciseNotes: String
    
    @State private var selectedMuscleGroup: String?
    @State private var selectedExerciseType: Int = 0
    
    @State private var confirmDelete: Bool = false
    @State private var stayOnPage: Bool = true
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    @State private var originalSnapshot: String?
    
    private var isValid: Bool {
        !exerciseName.trimmingCharacters(in: .whitespaces).isEmpty && selectedMuscleGroup != nil
    }
    
    init(selectedExercise: Binding<Exercise?> = .constant(nil)) {
        exerciseName = ""
        exerciseNotes = ""
        
        self._selectedExercise = selectedExercise
    }
    
    init(exercise: Exercise, selectedExercise: Binding<Exercise?> = .constant(nil)) {
        self.exercise = exercise
        
        exerciseName = exercise.name
        exerciseNotes = exercise.notes
        selectedMuscleGroup = exercise.muscleGroup?.rawValue ?? "Other"
        selectedExerciseType = ExerciseType.stringDisplayOrder.firstIndex(of: exercise.type.rawValue) ?? 0
        
        self._selectedExercise = selectedExercise
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
                                dismiss()
                            }
                        }
                        
                        Text("\(exercise == nil ? "ADD" : "EDIT") EXERCISE")
                            .headingText(size: 32)
                            .textColor()
                        
                        Spacer()
                        
                        if exercise != nil {
                            Button {
                                copyExercise()
                                
                                dismiss()
                            } label: {
                                Image(systemName: "document.on.document")
                                    .padding(.horizontal, 5)
                                    .font(Font.system(size: 20))
                            }
                            .textColor()
                            
                            Button {
                                Popup.show(content: {
                                    ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(exerciseName)?", resultText: "This will also remove it from all workouts.", cancelText: "Cancel", confirmText: "Delete")
                                })
                            } label: {
                                Image(systemName: "trash")
                                    .padding(.horizontal, 5)
                                    .font(Font.system(size: 20))
                            }
                            .textColor()
                            .onChange(of: confirmDelete) {
                                if confirmDelete {
                                    deleteExercise()
                                    
                                    try? context.save()
                                    
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Input(title: "Name", text: $exerciseName, isFocused: _isNameFocused, autoCapitalization: .words)
                                .frame(maxWidth: 250)
                            
                            
                            VStack(alignment: .leading) {
                                Text("Muscle Group")
                                    .bodyText(size: 12)
                                    .textColor()
                                
                                Button {
                                    Popup.show(content: {
                                        MenuPopup(title: "Muscle Group", options: MuscleGroup.stringDisplayOrder, selection: $selectedMuscleGroup)
                                    })
                                } label: {
                                    HStack(alignment: .center) {
                                        Text(selectedMuscleGroup ?? "Select")
                                            .bodyText(size: 18, weight: .bold)
                                        
                                        Image(systemName: "chevron.right")
                                            .padding(.leading, -2)
                                            .font(Font.system(size: 12, weight: .bold))
                                    }
                                }
                                .textColor()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Tracking Type")
                                    .bodyText(size: 12)
                                    .textColor()
                                
                                BRHSegmentedControl(
                                    selectedIndex: $selectedExerciseType,
                                    labels: ExerciseType.stringDisplayOrder,
                                    builder: { _, label in
                                        Text(label)
                                            .bodyText(size: 16)
                                    },
                                    styler: { state in
                                        switch state {
                                        case .none:
                                            return ColorManager.secondary
                                        case .touched:
                                            return ColorManager.secondary.opacity(0.7)
                                        case .selected:
                                            return ColorManager.text
                                        }
                                    }
                                )
                            }
                            
                            
                            Spacer()
                                .frame(height: 5)
                            
                            
                            Input(title: "Notes", text: $exerciseNotes, isFocused: _isNotesFocused, axis: .vertical)
                            
                            
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
                originalSnapshot = getSnapshot()
            }
        }
    }
    
    private func save() {
        if let exercise = exercise {
            exercise.name = exerciseName
            exercise.notes = exerciseNotes
            exercise.muscleGroup = MuscleGroup(rawValue: selectedMuscleGroup ?? "Other")
            exercise.type = ExerciseType.displayOrder[selectedExerciseType]
        } else {
            let exercise = Exercise(name: exerciseName, notes: exerciseNotes, muscleGroup: MuscleGroup(rawValue: selectedMuscleGroup ?? "Other") ?? .other, type: ExerciseType.displayOrder[selectedExerciseType])
            
            context.insert(exercise)
        }

        try? context.save()
        
        selectedExercise = exercise
        
        dismiss()
    }
    
    private func copyExercise() {
        if exercise != nil {
            let exerciseCopy = Exercise(name: "Copy of \(exerciseName)", notes: exerciseNotes, muscleGroup: MuscleGroup(rawValue: selectedMuscleGroup ?? "Other") ?? .other, type: ExerciseType.displayOrder[selectedExerciseType])
            
            context.insert(exerciseCopy)
            
            do {
                try context.save()
            } catch {
                debugLog("Failed to save workout copy: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteExercise() {
        if let exercise = exercise {
            exercise.hide()
            
            do {
                let workouts = (try context.fetch(FetchDescriptor<Workout>())).filter { $0.exercises.contains(where: { $0.exercise?.id == exercise.id }) }
                
                for workout in workouts {
                    workout.exercises.removeAll { $0.exercise?.id == exercise.id }
                }
                
                try context.save()
            } catch {
                debugLog("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func getSnapshot() -> String {
        let replacements = [("##:", "[DELIM]")]
        
        return "name:\(exerciseName.sanitize(replacements))##:notes:\(exerciseNotes.sanitize(replacements))##:muscleGroup:\(selectedMuscleGroup ?? "none")##:type:\(selectedExerciseType)##:"
    }
}
