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
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var workout: Workout
    
    @Query private var exercises: [Exercise]
    
    @State private var workoutExercise: WorkoutExercise
    @State private var exercise: Exercise?
    @State private var type: ExerciseType?
    
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var specNotes: String
    @State private var tempoArr: [String]
    
    @State private var showAlert: Bool = false
    
    @FocusState private var isNotesFocused: Bool
    
    @AppStorage(UserKeys.showTempo.rawValue) private var showTempo: Bool = false
    
    init(workout: Workout, exercise: Exercise?, workoutExercise: WorkoutExercise) {
        self.workout = workout
        self.exercise = exercise
        self._workoutExercise = State(initialValue: workoutExercise)
        type = exercise?.type
        
        let restTotalSeconds = Double(workoutExercise.restTime)
        let initialRestMinutes = Int(restTotalSeconds / 60)
        let initialRestSeconds = Int(restTotalSeconds - Double(initialRestMinutes * 60))
        let initialSpecNotes = workoutExercise.specNotes
        var initialTempoArr = workoutExercise.tempo.map { String($0) }
        
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
                            NavigationLink(destination: SelectExercise(selectedExercise: $exercise)) {
                                Text(exercise?.name ?? "Select Exercise")
                            }
                            .textColor()
                        }
                        .lineLimit(2)
                        .truncationMode(.tail)
                    }
                    .frame(height: 100)
                    .scrollContentBackground(.hidden)
                    .onChange(of: exercise) {
                        if exercise?.type != type {
                            type = exercise?.type ?? .weight
                            workoutExercise.sets.removeAll()
                        }
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
                                    let type = type ?? .weight
                                    
                                    Task {
                                        if type == .weight {
                                            await EditWeightSetPopup(set: set).present()
                                        } else if type == .distance {
                                            await EditDistanceSetPopup(set: set).present()
                                        }
                                    }
                                } label: {
                                    SetView(set: set)
                                }
                                .textColor()
                                .swipeActions {
                                    Button("Delete") {
                                        var updatedSets = workoutExercise.sets
                                        updatedSets.remove(at: index)
                                        workoutExercise.sets = updatedSets
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
                        var updatedSets = workoutExercise.sets
                        
                        let nextIndex = updatedSets.isEmpty ? 0 : (updatedSets.map { $0.index } .max() ?? -1) + 1
                        
                        let newSet = ExerciseSet(index: nextIndex, type: type ?? .weight)
                        updatedSets.append(newSet)
                        
                        workoutExercise.sets = updatedSets
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
        
        workoutExercise.exercise = exercise
        
        let restTotalSeconds = (Double(restMinutes) * 60) + Double(restSeconds)
        workoutExercise.restTime = restTotalSeconds
        
        workoutExercise.specNotes = specNotes
        
        workoutExercise.tempo = tempoArr.joined()
        
        dismiss()
    }
    
    private func tempoPicker() -> some View {
        ForEach(["X", "1", "2", "3", "4", "5", "6", "7", "8", "9"], id: \.self) { num in
            Text(num)
                .tag(num)
        }
    }
}
