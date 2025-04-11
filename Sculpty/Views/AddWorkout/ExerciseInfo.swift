//
//  ExerciseInfo.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/14/25.
//

import SwiftUI
import SwiftData
import Neumorphic
import MijickPopups

struct ExerciseInfo: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    private var workout: Workout = Workout()
    
    @Binding var workoutExercise: WorkoutExercise
    @State private var exercise: Exercise? = nil
    
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var specNotes: String
    @State private var tempoArr: [String]
    
    @State private var selectingExercise: Bool = false
    @State private var showAlert: Bool = false
    
    @FocusState private var isNotesFocused: Bool
    
    @AppStorage(UserKeys.showTempo.rawValue) private var showTempo: Bool = false
    
    init(workout: Workout, exercise: Exercise?, workoutExercise: Binding<WorkoutExercise>) {
        self.workout = workout
        self.exercise = exercise
        self._workoutExercise = workoutExercise
        
        let restTotalSeconds = Double(workoutExercise.restTime.wrappedValue)
        let initialRestMinutes = Int(restTotalSeconds / 60)
        let initialRestSeconds = Int(restTotalSeconds - Double(initialRestMinutes * 60))
        let initialSpecNotes = workoutExercise.specNotes.wrappedValue
        var initialTempoArr = workoutExercise.tempo.wrappedValue.map { String($0) }
        
        while initialTempoArr.count < 4 {
            initialTempoArr.append("X")
        }
        if initialTempoArr.count > 4 {
            initialTempoArr = Array(initialTempoArr.prefix(4))
        }
        
        _restMinutes = State(initialValue: initialRestMinutes)
        _restSeconds = State(initialValue: initialRestSeconds)
        _specNotes = State(initialValue: initialSpecNotes)
        _tempoArr = State(initialValue: initialTempoArr)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                ScrollView {
                    // Exercise Display
                    List {
                        HStack {
                            Button {
                                selectingExercise = true
                            } label: {
                                Text(exercise?.name ?? "Select Exercise")
                            }
                            .textColor()
                        }
                        .lineLimit(2)
                        .truncationMode(.tail)
                    }
                    .frame(height: 100)
                    .scrollContentBackground(.hidden)
                    .sheet(isPresented: $selectingExercise) {
                        SelectExercise(selectedExercise: $exercise, selectingExercise: $selectingExercise)
                    }
                    
                    // Exercise Notes
                    if workoutExercise.exercise != nil && workoutExercise.exercise?.notes != "" {
                        HStack {
                            Text(workoutExercise.exercise!.notes)
                            
                            Spacer()
                        }
                    }
                    
                    
                    Spacer()
                    
                    
                    // Sets
                    List {
                        ForEach(workoutExercise.sets.sorted { $0.index < $1.index }, id: \.id) { set in
                            if let index = workoutExercise.sets.firstIndex(of: set) {
                                Button {
                                    let type = set.exerciseType
                                    
                                    Task {
                                        if type == .weight {
                                            await EditWeightSetPopup(set: $workoutExercise.sets[index]).present()
                                        } else if type == .distance {
                                            await EditDistanceSetPopup(set: $workoutExercise.sets[index]).present()
                                        }
                                    }
                                } label: {
                                    SetView(set: set)
                                }
                                .textColor()
                                .swipeActions {
                                    Button("Delete") {
                                        workoutExercise.deleteSet(at: index)
                                    }
                                    .tint(.red)
                                }
                            }
                        }
                        .onMove { from, to in
                            var reordered = workoutExercise.sets
                            
                            reordered.move(fromOffsets: from, toOffset: to)
                            
                            for (newIndex, set) in reordered.enumerated() {
                                if set.index != newIndex {
                                    set.index = newIndex
                                }
                            }
                            
                            workoutExercise.sets = reordered
                        }
                    }
                    .frame(height: CGFloat((workoutExercise.sets.count * 66) + (workoutExercise.sets.count < 5 ? (workoutExercise.sets.count < 4 ? (workoutExercise.sets.count < 3 ? (workoutExercise.sets.count < 2 ? 50 : 40) : 30) : 20) : 0)), alignment: .top)
                    .scrollDisabled(true)
                    .scrollContentBackground(.hidden)

                    Button {
                        let nextIndex: Int
                        if workoutExercise.sets.isEmpty {
                            nextIndex = 0
                        } else {
                            let indices = workoutExercise.sets.map { $0.index }
                            nextIndex = (indices.max() ?? -1) + 1
                        }
                        workoutExercise.sets.append(ExerciseSet(index: nextIndex, type: (workoutExercise.exercise?.type ?? .weight)))
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Set")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    
                    Spacer()
                    
                    
                    // Rest Time Picker
                    HStack(spacing: 20) {
                        Text("Rest Time")
                        
                        // Minutes Picker
                        Picker("Minutes", selection: $restMinutes) {
                            ForEach(Array(0...59), id: \.self) { minute in
                                Text("\(minute) min")
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: 100)
                        .clipped()
                        
                        // Seconds Picker
                        Picker("Seconds", selection: $restSeconds) {
                            ForEach([0, 15, 30, 45], id: \.self) { second in
                                Text("\(second) sec")
                                    .tag(second)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: 100)
                        .clipped()
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    .frame(height: 125)
                    
                    // Tempo
                    if showTempo {
                        HStack (spacing: 5) {
                            Button {
                                Task {
                                    await TempoPopup(tempo: tempoArr.joined(separator: "")).present()
                                }
                            } label: {
                                Text("Tempo")
                            }
                            
                            Picker("Tempo 1", selection: $tempoArr[0]) {
                                tempoPicker()
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: 50)
                            .clipped()
                            
                            Picker("Tempo 2", selection: $tempoArr[1]) {
                                tempoPicker()
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: 50)
                            .clipped()
                            
                            Picker("Tempo 3", selection: $tempoArr[2]) {
                                tempoPicker()
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: 50)
                            .clipped()
                            
                            Picker("Tempo 4", selection: $tempoArr[3]) {
                                tempoPicker()
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: 50)
                            .clipped()
                        }
                        .frame(height: 100)
                        .padding(.bottom)
                    }
                    
                    // Workout-specific notes
                    TextField("Workout-Specific Notes", text: $specNotes, axis: .vertical)
                        .padding(.horizontal)
                        .focused($isNotesFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    Button("Save") {
                        save()
                    }
                    .buttonStyle(.borderedProminent)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"),
                              message: Text("Please select an exercise"))
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItemGroup (placement: .keyboard) {
                        Spacer()
                        
                        Button {
                            isNotesFocused = false
                        } label: {
                            Text("Done")
                        }
                        .disabled(!isNotesFocused)
                    }
                }
            }
        }
    }
    
    
    
    private func save() {
        guard !workoutExercise.sets.isEmpty && exercise != nil else {
            showAlert = true
            return
        }
        
        // Exercise
        workoutExercise.exercise = exercise
        
        // Sets
        for set in workoutExercise.sets {
            if set.exerciseType == .weight,
               let reps = set.reps {
                set.reps = max(0, reps)
            }
        }
        
        // Rest
        let restTotalSeconds = (Double(restMinutes) * 60) + Double(restSeconds)
        workoutExercise.restTime = TimeInterval(restTotalSeconds)
        
        // Workout-specific notes
        workoutExercise.specNotes = specNotes
        
        // Tempo
        workoutExercise.tempo = tempoArr.joined()
        
        // Save
        if !workout.exercises.contains(workoutExercise) {
            workout.exercises.append(workoutExercise)
        }
        
        dismiss()
    }
    
    private func tempoPicker() -> some View {
        ForEach(["X", "1", "2", "3", "4", "5", "6", "7", "8", "9"], id: \.self) { num in
            Text(num)
                .tag(num)
        }
    }
}
