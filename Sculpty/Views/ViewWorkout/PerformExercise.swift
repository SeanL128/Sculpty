//
//  PerformExercise.swift
//  Sculpty
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
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    Text(exercise.exercise?.name ?? "Exercise")
                        .font(.headline)
                    
                    List {
                        ForEach(exercise.sets.sorted { $0.index < $1.index }, id: \.id) { set in
                            var setIndex: Int {
                                exercise.sets.firstIndex { $0.index == set.index } ?? -1
                            }
                            var logIndex: Int {
                                return log.setLogs.firstIndex { $0.index == set.index } ?? -1
                            }
                            
                            var backgroundColor: Color {
                                if log.setLogs[logIndex].completed {
                                    return Color.accentColor
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
                                SetView(set: set)
                            }
                            .textColor()
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
                .padding(.bottom, 50)
            }
        }
    }
    
    private func dismissed(setIndex: Int, logIndex: Int) -> () -> Void {
        {
            if !workoutLog.started {
                workoutLog.startWorkout()
            }
            
            if exerciseStatus == 2 {
                let set = exercise.sets[setIndex]
                let weight = set.measurement == "x" ? Double(set.reps) * set.weight : 0
                
                log.setLogs[logIndex].unskip()
                log.setLogs[logIndex].finish(reps: set.reps, weight: weight, measurement: set.measurement)
                
                switch (set.type) {
                case (.warmUp):
                    timeRemaining = 30
                case (.coolDown):
                    timeRemaining = 60
                default:
                    timeRemaining = exercise.restTime
                }
            } else if exerciseStatus == 3 {
                log.setLogs[logIndex].unfinish()
                log.setLogs[logIndex].skip()
            } else if exerciseStatus == 4 {
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
