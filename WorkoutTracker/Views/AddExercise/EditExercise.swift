//
//  EditMovement.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData

struct EditExercise: View {
    // Environment Variables
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // View Model
    @StateObject private var viewModel: ExerciseViewModel
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool

    init(exercise: Exercise) {
        _viewModel = StateObject(wrappedValue: ExerciseViewModel(exercise: exercise))
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Name
                TextField("Name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                    .focused($isNameFocused)
                
                // Notes
                TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($isNotesFocused)
                
                
                Spacer()
                
                
                // Display Selected Muscle Group
                Text("Selected: \(viewModel.muscleGroup.rawValue.capitalized)")
                    .font(.subheadline)
                    .padding()
                
                // Select Muscle Groups
                Menu {
                    ForEach(MuscleGroup.displayOrder, id: \.self) { muscleGroup in
                        Button(action: {
                            viewModel.muscleGroup = viewModel.muscleGroup == muscleGroup ? MuscleGroup.other : muscleGroup
                        }) {
                            HStack {
                                Text(muscleGroup.rawValue.capitalized)
                                if viewModel.muscleGroup == muscleGroup {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Text("Select Muscle Groups")
                }
                .padding(.bottom, 25)
                
                Button("Save Exercise") {
                    viewModel.save(context: context, insert: false)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty
                )

            }
            .padding()
            .navigationTitle(Text("Edit Exercise"))
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
    EditExercise(exercise: Exercise())
}
