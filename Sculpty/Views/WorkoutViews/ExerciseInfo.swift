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
    
    private var workout: Workout
    
    @Query private var exercises: [Exercise]
    
    @State private var workoutExercise: WorkoutExercise
    @State private var exercise: Exercise?
    @State private var type: ExerciseType?
    private var sortedSets: [ExerciseSet] { workoutExercise.sets.sorted { $0.index < $1.index } }
    
    // Store original values for change tracking
    private let originalExercise: Exercise?
    private let originalRestTime: TimeInterval
    private let originalSpecNotes: String
    private let originalTempo: String
    private let originalSets: [ExerciseSet]
    
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var specNotes: String
    @State private var tempo: String
    
    @FocusState private var isNotesFocused: Bool
    @FocusState private var isTempoFocused: Bool
    
    @State private var editing: Bool = false
    
    private var isValid: Bool {
        !workoutExercise.sets.isEmpty && exercise != nil
    }
    
    @State private var stayOnPage: Bool = true
    
    private var hasChanges: Bool {
        if exercise?.id != originalExercise?.id {
            return true
        }
        
        let currentRestTime = (Double(restMinutes) * 60) + Double(restSeconds)
        if currentRestTime != originalRestTime {
            return true
        }
        
        if specNotes != originalSpecNotes {
            return true
        }
        
        var currentTempo = tempo
        while currentTempo.count < 4 {
            currentTempo.append("0")
        }
        if currentTempo != originalTempo {
            return true
        }
        
        if workoutExercise.sets.count != originalSets.count {
            return true
        }
        
        let currentSets = workoutExercise.sets.sorted { $0.index < $1.index }
        let sortedOriginalSets = originalSets.sorted { $0.index < $1.index }
        
        for (currentSet, originalSet) in zip(currentSets, sortedOriginalSets) {
            if currentSet.index != originalSet.index ||
               currentSet.unit != originalSet.unit ||
               currentSet.type != originalSet.type ||
               currentSet.exerciseType != originalSet.exerciseType {
                return true
            }
            
            if currentSet.exerciseType == .weight {
                if currentSet.reps != originalSet.reps ||
                   currentSet.weight != originalSet.weight ||
                   currentSet.rir != originalSet.rir {
                    return true
                }
            }
            
            if currentSet.exerciseType == .distance {
                if currentSet.time != originalSet.time ||
                   currentSet.distance != originalSet.distance {
                    return true
                }
            }
        }
        
        return false
    }
    
    init(workout: Workout, exercise: Exercise?, workoutExercise: WorkoutExercise) {
        self.workout = workout
        self.exercise = exercise
        self._workoutExercise = State(initialValue: workoutExercise)
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
        
        originalExercise = exercise
        originalRestTime = workoutExercise.restTime
        originalSpecNotes = workoutExercise.specNotes
        originalTempo = initialTempo
        originalSets = workoutExercise.sets.map { $0.copy() }
    }

    var body: some View {
        ContainerView(title: "Exercise Info", spacing: 20, onDismiss: { save() }) {
            VStack(alignment: .leading, spacing: 20) {
                NavigationLink(destination: SelectExercise(selectedExercise: $exercise)) {
                    HStack(alignment: .center) {
                        Text(exercise?.name ?? "Select Exercise")
                            .bodyText(size: 20, weight: .bold)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 14, weight: .bold))
                    }
                }
                .textColor()
                .onChange(of: exercise) {
                    if exercise?.type != type {
                        workoutExercise.sets.removeAll()
                    }
                    
                    type = exercise?.type
                }
                
                if let notes = workoutExercise.exercise?.notes, !notes.isEmpty {
                    Text(workoutExercise.exercise!.notes)
                        .bodyText(size: 16)
                        .textColor()
                }
            }
            
            if sortedSets.count > 0 {
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
                ForEach(workoutExercise.sets.sorted { $0.index < $1.index }, id: \.id) { set in
                    if let index = workoutExercise.sets.firstIndex(of: set) {
                        HStack(alignment: .center) {
                            if editing {
                                VStack(alignment: .center, spacing: 10) {
                                    Button {
                                        if let above = sortedSets.last(where: { $0.index < set.index }) {
                                            let index = set.index
                                            set.index = above.index
                                            above.index = index
                                        }
                                    } label: {
                                        Image(systemName: "chevron.up")
                                            .font(Font.system(size: 14))
                                    }
                                    .foregroundStyle(sortedSets.last(where: { $0.index < set.index }) == nil ? ColorManager.secondary : ColorManager.text)
                                    .disabled(sortedSets.last(where: { $0.index < set.index }) == nil)
                                    
                                    Button {
                                        if let below = sortedSets.first(where: { $0.index > set.index }) {
                                            let index = set.index
                                            set.index = below.index
                                            below.index = index
                                        }
                                    } label: {
                                        Image(systemName: "chevron.down")
                                            .font(Font.system(size: 14))
                                    }
                                    .foregroundStyle(sortedSets.first(where: { $0.index > set.index }) == nil ? ColorManager.secondary : ColorManager.text)
                                    .disabled(sortedSets.first(where: { $0.index > set.index }) == nil)
                                }
                            }
                            
                            Button {
                                let type = type ?? .weight
                                
                                switch type {
                                case .weight:
                                    Popup.show(content: {
                                        EditWeightSetPopup(set: set)
                                    })
                                case .distance:
                                    Popup.show(content: {
                                        EditDistanceSetPopup(set: set)
                                    })
                                }
                            } label: {
                                SetView(set: set)
                            }
                            .textColor()
                            
                            Spacer()
                            
                            Button {
                                var updatedSets = workoutExercise.sets
                                updatedSets.remove(at: index)
                                workoutExercise.sets = updatedSets
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
            
            Button {
                var updatedSets = workoutExercise.sets
                
                let nextIndex = updatedSets.isEmpty ? 0 : (updatedSets.map { $0.index }.max() ?? -1) + 1
                
                let newSet = ExerciseSet(index: nextIndex, type: type ?? .weight)
                updatedSets.append(newSet)
                
                workoutExercise.sets = updatedSets
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus")
                        .font(Font.system(size: 12, weight: .bold))
                    
                    Text("Add Set")
                        .bodyText(size: 16, weight: .bold)
                }
            }
            .textColor()
            
            
            Spacer()
                .frame(height: 5)
            
            
            Button {
                Popup.show(content: {
                    DurationSelectionPopup(title: "Rest Time", minutes: $restMinutes, seconds: $restSeconds)
                })
            } label: {
                HStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 0) {
                        Text("Rest Time:")
                            .bodyText(size: 18, weight: .bold)
                        
                        Text(" \(restMinutes)min \(restSeconds)sec")
                            .bodyText(size: 18)
                    }
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12, weight: .bold))
                }
            }
            .textColor()
            
            
            Spacer()
                .frame(height: 5)
            
            
            if settings.showTempo {
                VStack(alignment: .leading) {
                    Button {
                        Popup.show(content: {
                            TempoPopup(tempo: tempo)
                        })
                    } label: {
                        HStack {
                            Text("Tempo")
                                .bodyText(size: 12)
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 6))
                        }
                    }
                    .textColor()
                    
                    HStack(alignment: .bottom) {
                        TextField("", text: $tempo, prompt: Text("0000"))
                            .keyboardType(.numberPad)
                            .focused($isTempoFocused)
                            .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isTempoFocused }, set: { isTempoFocused = $0 }), text: $tempo))
                            .onChange(of: tempo) {
                                if tempo.count > 4 {
                                    tempo = String(tempo.prefix(4))
                                }
                            }
                    }
                    .frame(maxWidth: 50)
                }
            }
            
            
            Spacer()
                .frame(height: 5)
            
            
            Input(title: "Workout-Specific Notes", text: $specNotes, isFocused: _isNotesFocused, axis: .vertical)
            
            
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
                
                KeyboardDoneButton(focusStates: [_isNotesFocused, _isTempoFocused])
            }
        }
    }
    
    private func save() {
        if !sortedSets.isEmpty {
            workoutExercise.exercise = exercise
            
            let restTotalSeconds = (Double(restMinutes) * 60) + Double(restSeconds)
            workoutExercise.restTime = restTotalSeconds
            
            workoutExercise.specNotes = specNotes
            
            while tempo.count < 4 {
                tempo.append("0")
            }
            workoutExercise.tempo = tempo
        }
        
        dismiss()
    }
}
