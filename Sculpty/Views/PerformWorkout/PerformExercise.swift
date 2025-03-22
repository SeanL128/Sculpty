//
//  PerformExercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/16/25.
//

import SwiftUI
import MijickPopups

struct PerformExercise: View {
    @Environment(\.modelContext) private var context
    
    private var workout: Workout
    private var workoutLog: WorkoutLog
    
    @State private var exercise: WorkoutExercise
    @State private var log: ExerciseLog
    @Binding private var timeRemaining: Double
    
    @State private var finish: Bool = false
    
    @State private var exerciseStatus: Int = 1
    
    @AppStorage(UserKeys.showTempo.rawValue) private var showTempo: Bool = false
    
    init(exerciseLog: ExerciseLog, time: Binding<Double> = .constant(0)) {
        self.log = exerciseLog
        
        self.workoutLog = exerciseLog.workoutLog!
        self.workout = exerciseLog.workoutLog!.workout
        self._timeRemaining = time
        
        self.exercise = exerciseLog.exercise
    }
    
    var body: some View {
        let _ = Self._printChanges()
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    Text(exercise.exercise?.name ?? "Exercise")
                        .font(.headline)
                    
                    List {
                        ForEach(exercise.sets.sorted { $0.index < $1.index }, id: \.id) { set in
                            let setIndex: Int = set.index
                            
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
                                Task {
                                    await EditSetPopup(set: $exercise.sets[setIndex], log: $log.setLogs[logIndex], timeRemaining: $timeRemaining, restTime: exercise.restTime).present()
                                    
                                    if log.setLogs[logIndex].completed {
                                        switch (set.type) {
                                        case (.warmUp):
                                            timeRemaining = 30
                                        case (.coolDown):
                                            timeRemaining = 60
                                        default:
                                            timeRemaining = exercise.restTime
                                        }
                                    }
                                    
                                    checkAllDone()
                                }
                            } label: {
                                SetView(set: set)
                            }
                            .disabled(log.setLogs.filter { $0.completed || $0.skipped }.count < setIndex)
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
                    
                    if showTempo {
                        HStack {
                            Button {
                                Task {
                                    await TempoPopup(tempo: exercise.tempo).present()
                                }
                            } label: {
                                Text(exercise.tempo)
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private func dismissed(setIndex: Int, logIndex: Int) {
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
        
        exerciseStatus = 1
        
        checkAllDone()
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
    PerformExercise(exerciseLog: workoutLog.exerciseLogs[0])
}
