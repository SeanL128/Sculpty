//
//  PerformExercise.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/16/25.
//

import SwiftUI

struct PerformExercise: View {
    @Environment(\.modelContext) private var context
    
    private var workout: Workout
    private var workoutLog: WorkoutLog
    private var index: Int
    
    @State private var exercise: WorkoutExercise
    @State private var log: ExerciseLog
    @Binding private var timeRemaining: Double
    
    @State private var finish: Bool = false
    
    @State private var editingIndex: (IdentifiableIndex, IdentifiableIndex) = (IdentifiableIndex(id: -1), IdentifiableIndex(id: -1))
    @State private var showEditSet: Bool = false
    @State private var exerciseStatus: Int = 1
    @State private var showTempoSheet: Bool = false
    
    init(workout: Workout, log: WorkoutLog, index: Int, time: Binding<Double> = .constant(0)) {
        self.workout = workout
        self.workoutLog = log
        self.index = index
        self._timeRemaining = time
        
        self.exercise = workout.exercises[workout.exercises.firstIndex { $0.index == index }!]
        self.log = log.exerciseLogs[log.exerciseLogs.firstIndex { $0.index == index }!]
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(exercise.exercise?.name ?? "Exercise")
                    .font(.headline)
                
                List {
                    ForEach(exercise.sets.sorted { $0.index < $1.index }, id: \.self) { set in
                        var setIndex: Int {
                            exercise.sets.firstIndex { $0.index == set.index } ?? -1
                        }
                        var logIndex: Int {
                            return log.setLogs.firstIndex { $0.index == set.index } ?? -1
                        }
                        
                        var backgroundColor: Color {
                            if log.setLogs[logIndex].completed {
                                return .accent
                            }
                            
                            if log.setLogs[logIndex].skipped {
                                return .gray
                            }
                            
                            return Color(UIColor.systemBackground)
                        }
                        
                        Button {
                            editingIndex.0.id = setIndex
                            editingIndex.1.id = logIndex
                            showEditSet = true
                        } label: {
                            setView(for: set)
                        }
                        .foregroundStyle(textColor)
                        .swipeActions {
                            Button("Skip") {
                                log.setLogs[logIndex].unfinish()
                                log.setLogs[logIndex].skip()
                                checkAllDone()
                            }
                            .tint(.gray)
                        }
                        .listRowBackground(backgroundColor)
                    }
                }
                .scrollContentBackground(.hidden)
                .sheet(isPresented: $showEditSet, onDismiss: dismissed(setIndex: $editingIndex.0.id, logIndex: $editingIndex.1.id)) {
                    EditSet(set: $exercise.sets[editingIndex.0.id], exerciseStatus: $exerciseStatus, isPresented: $showEditSet)
                        .presentationDetents([.fraction(0.35), .medium])
                }
                
                HStack {
                    Button {
                        showTempoSheet = true
                    } label: {
                        Text(exercise.tempo)
                    }
                }
                .sheet(isPresented: $showTempoSheet) {
                    TempoSheet(tempo: exercise.tempo)
                        .presentationDetents([.fraction(0.2), .medium])
                }
            }
            .navigationBarHidden(true)
            .padding(.bottom, 50)
        }
    }
    
    private func setView(for set: ExerciseSet) -> some View {
        HStack {
            ZStack {
                switch (set.type) {
                case ("Warm Up"):
                    Image(systemName: "bolt.fill")
                case ("Drop Set"):
                    Image(systemName: "arrowtriangle.down.fill")
                case ("Cool Down"):
                    Image(systemName: "drop.fill")
                default:
                    Text("")
                }
            }
            .frame(width: 20, height: 40)
            
            Text("\(set.reps) \(set.measurement) \(String(format: "%0.2f", set.weight)) lbs")
            
            Spacer()
            
            if !["Warm Up", "Cool Down"].contains(set.type) {
                if set.rir == "Failure" {
                    Text(set.rir)
                } else {
                    Text("\(set.rir) RIR")
                }
            }
        }
        .frame(height: 37)
    }
    
    private func dismissed(setIndex: Int, logIndex: Int) -> () -> Void {
        {
            if exerciseStatus == 2 {
                workoutLog.started = true
                workoutLog.start = Date().timeIntervalSince1970.rounded(.down)
                
                let set = exercise.sets[setIndex]
                let weight = set.measurement == "x" ? Double(set.reps) * set.weight : 0
                
                log.setLogs[logIndex].unskip()
                log.setLogs[logIndex].finish(weight: weight, reps: set.reps)
                
                switch (set.type) {
                case ("Warm Up"):
                    timeRemaining = 30
                case ("Cool Down"):
                    timeRemaining = 60
                default:
                    timeRemaining = exercise.restTime
                }
            } else if exerciseStatus == 3 {
                workoutLog.started = true
                
                log.setLogs[logIndex].unfinish()
                log.setLogs[logIndex].skip()
            } else if exerciseStatus == 4 {
                workoutLog.started = true
                
                log.setLogs[logIndex].unskip()
                log.setLogs[logIndex].unfinish()
                
                timeRemaining = 0
            }
            
            editingIndex.0.id = -1
            editingIndex.1.id = -1
            exerciseStatus = 1
            
            checkAllDone()
        }
    }
    
    private func checkAllDone() {
        var allDone: Bool = true
        
        for log in log.setLogs {
            if !log.completed && !log.skipped {
                allDone = false
                break
            }
        }
        
        if allDone {
            log.finish()
        }
        
        try? context.save()
    }
}

#Preview {
    let workout = Workout(exercises: [WorkoutExercise(exercise: Exercise(), sets: [ExerciseSet(), ExerciseSet(), ExerciseSet()])])
    let workoutLog = WorkoutLog(workout: workout)
    PerformExercise(workout: workout, log: workoutLog, index: 0)
}
