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
    
    @State var exercise: Exercise
    
    @Binding var selectedExercise: Exercise?
    
    @State var new: Bool
    
    @State private var selectedMuscleGroup: String?
    @State private var selectedExerciseType: Int = 0
    
    @State private var confirmDelete: Bool = false
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    private var isValid: Bool {
        !exercise.name.trimmingCharacters(in: .whitespaces).isEmpty && selectedMuscleGroup != nil
    }
    
    init(exercise: Exercise = Exercise(), selectedExercise: Binding<Exercise?> = .constant(nil)) {
        self.exercise = exercise
        
        new = (exercise.name == "")
        
        self._selectedExercise = selectedExercise
    }
    
    var body: some View {
        ContainerView(title: "\(new ? "Add" : "Edit") Exercise", spacing: 20, trailingItems: {
            if !new {
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
                        ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(exercise.name)?", resultText: "This will also remove it from all workouts.", cancelText: "Cancel", confirmText: "Delete")
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
        }) {
            Input(title: "Name", text: $exercise.name, isFocused: _isNameFocused, autoCapitalization: .words)
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
                .onChange(of: selectedMuscleGroup) {
                    exercise.muscleGroup = MuscleGroup(rawValue: selectedMuscleGroup ?? "Other")
                }
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
                .onChange(of: selectedExerciseType) {
                    exercise.type = ExerciseType.displayOrder[selectedExerciseType]
                }
            }
            
            
            Spacer()
                .frame(height: 5)
            
            
            Input(title: "Notes", text: $exercise.notes, isFocused: _isNotesFocused, axis: .vertical)
            
            
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
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                KeyboardDoneButton(focusStates: [_isNameFocused, _isNotesFocused])
            }
        }
        .onAppear() {
            if !new {
                selectedMuscleGroup = exercise.muscleGroup?.rawValue ?? "Other"
                selectedExerciseType = ExerciseType.stringDisplayOrder.firstIndex(of: exercise.type.rawValue) ?? 0
            }
        }
    }
    
    private func save() {
        if new {
            context.insert(exercise)
        }
        
        try? context.save()
        
        selectedExercise = exercise
        
        dismiss()
    }
    
    private func copyExercise() {
        if !new {
            let exerciseCopy = Exercise(name: "Copy of \(exercise.name)", notes: exercise.notes, muscleGroup: exercise.muscleGroup ?? .other, type: exercise.type)
            
            context.insert(exerciseCopy)
            
            do {
                try context.save()
            } catch {
                debugLog("Failed to save workout copy: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteExercise() {
        if !new {
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
}
