//
//  ExerciseInfo.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/14/25.
//

import SwiftUI
import SwiftData

struct ExerciseInfo: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var settings: CloudSettings
    
    @State private var workoutExercise: WorkoutExercise
    @State private var exercise: Exercise?
    @State private var type: ExerciseType?
    private var sortedSets: [ExerciseSet] { workoutExercise.sets.sorted { $0.index < $1.index } }
    
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var specNotes: String
    @State private var tempo: String
    
    @FocusState private var isNotesFocused: Bool
    @FocusState private var isTempoFocused: Bool
    
    private var onChangesMade: (() -> Void)?
    
    private var isValid: Bool {
        !workoutExercise.sets.isEmpty && exercise != nil
    }
    
    init(exercise: Exercise?, workoutExercise: WorkoutExercise, onChangesMade: (() -> Void)? = nil) {
        self.exercise = exercise
        self._workoutExercise = State(initialValue: workoutExercise)
        self.onChangesMade = onChangesMade
        type = exercise?.type
        
        let restTotalSeconds = Double(workoutExercise.restTime)
        let initialRestMinutes = Int(restTotalSeconds / 60)
        let initialRestSeconds = Int(restTotalSeconds - Double(initialRestMinutes * 60))
        let initialSpecNotes = workoutExercise.specNotes
        var initialTempo = workoutExercise.tempo
        
        while initialTempo.count < 4 {
            initialTempo.append("0")
        }
        if initialTempo.count > 4 {
            initialTempo = String(initialTempo.prefix(4))
        }
        
        _restMinutes = State(initialValue: initialRestMinutes)
        _restSeconds = State(initialValue: initialRestSeconds)
        _specNotes = State(initialValue: initialSpecNotes)
        _tempo = State(initialValue: initialTempo)
    }

    var body: some View {
        ContainerView(title: "Exercise Info", spacing: .spacingXXL, onDismiss: {
            if !workoutExercise.sets.isEmpty {
                save(false)
            }
        }) {
            VStack(alignment: .leading, spacing: .spacingXL) {
                VStack(alignment: .leading, spacing: .spacingM) {
                    NavigationLink {
                        SelectExercise(selectedExercise: $exercise)
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            Text(exercise?.name ?? "Select Exercise")
                                .subheadingText()
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.leading)
                                .animation(.easeInOut(duration: 0.3), value: exercise?.name)
                            
                            Image(systemName: "chevron.right")
                                .subheadingImage()
                        }
                    }
                    .textColor()
                    .animatedButton()
                    .onChange(of: exercise) {
                        if exercise?.type != type {
                            workoutExercise.sets.removeAll()
                        }
                        
                        type = exercise?.type
                        
                        if workoutExercise.sets.isEmpty {
                            let newSet = ExerciseSet(index: 0, type: type ?? .weight)
                            
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                var updatedSets = workoutExercise.sets
                                
                                updatedSets.append(newSet)
                                
                                workoutExercise.sets = updatedSets
                            }
                        }
                    }
                    
                    if let notes = workoutExercise.exercise?.notes, !notes.isEmpty {
                        Text(notes)
                            .bodyText()
                            .textColor()
                            .multilineTextAlignment(.leading)
                    }
                }
                
                if exercise != nil {
                    if !workoutExercise.sets.isEmpty {
                        VStack(alignment: .leading, spacing: .listSpacing) {
                            ForEach(workoutExercise.sets.sorted { $0.index < $1.index }, id: \.id) { set in
                                EditSetRow(
                                    set: set,
                                    sortedSets: sortedSets,
                                    type: type,
                                    workoutExercise: $workoutExercise
                                )
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .leading)),
                                    removal: .opacity.combined(with: .move(edge: .trailing))
                                ))
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: sortedSets.count)
                    }
                    
                    Button {
                        let nextIndex = workoutExercise.sets.isEmpty ? 0 : (workoutExercise.sets.map { $0.index }.max() ?? -1) + 1 // swiftlint:disable:this line_length
                        
                        let newSet = ExerciseSet(index: nextIndex, type: type ?? .weight)
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            var updatedSets = workoutExercise.sets
                            
                            updatedSets.append(newSet)
                            
                            workoutExercise.sets = updatedSets
                        }
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            Image(systemName: "plus")
                                .secondaryImage(weight: .bold)
                            
                            Text("Add Set")
                                .secondaryText()
                        }
                    }
                    .textColor()
                    .animatedButton(feedback: .impact(weight: .light))
                }
                
                Button {
                    Popup.show(content: {
                        DurationSelectionPopup(title: "Rest Time", minutes: $restMinutes, seconds: $restSeconds)
                    })
                } label: {
                    HStack(alignment: .center, spacing: .spacingXS) {
                        Text("Rest Time: \(restMinutes)min \(restSeconds)sec")
                            .bodyText()
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: restMinutes)
                            .animation(.easeInOut(duration: 0.3), value: restSeconds)
                        
                        Image(systemName: "chevron.right")
                            .bodyImage()
                    }
                }
                .textColor()
                .animatedButton()
                
                if settings.showTempo {
                    VStack(alignment: .leading, spacing: .spacingXS) {
                        Button {
                            Popup.show(content: {
                                TempoPopup(tempo: tempo)
                            })
                        } label: {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text("Tempo")
                                    .captionText()
                                
                                Image(systemName: "chevron.right")
                                    .captionImage()
                            }
                        }
                        .textColor()
                        .animatedButton()
                        
                        HStack(alignment: .bottom) {
                            TextField("", text: $tempo, prompt: Text("0000"))
                                .keyboardType(.numberPad)
                                .focused($isTempoFocused)
                                .textFieldStyle(
                                    UnderlinedTextFieldStyle(
                                        isFocused: Binding<Bool>(
                                            get: { isTempoFocused },
                                            set: { isTempoFocused = $0 }
                                        ),
                                        text: $tempo
                                    )
                                )
                                .onChange(of: tempo) {
                                    if tempo.count > 4 {
                                        tempo = String(tempo.prefix(4))
                                    }
                                }
                        }
                        .frame(maxWidth: 50)
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                }
                
                Input(title: "Notes", text: $specNotes, isFocused: _isNotesFocused, axis: .vertical)
            }
            
            HStack(alignment: .center) {
                Spacer()
                
                SaveButton(save: save, isValid: isValid)
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
    
    private func save() { save(true) }
    
    private func save(_ dismissAfter: Bool = true) {
        if !sortedSets.isEmpty {
            workoutExercise.exercise = exercise
            
            let restTotalSeconds = (Double(restMinutes) * 60) + Double(restSeconds)
            workoutExercise.restTime = restTotalSeconds
            
            workoutExercise.specNotes = specNotes
            
            while tempo.count < 4 {
                tempo.append("0")
            }
            workoutExercise.tempo = tempo
            
            onChangesMade?()
        }
        
        if dismissAfter {
            dismiss()
        }
    }
}
