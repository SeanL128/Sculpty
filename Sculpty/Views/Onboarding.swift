//
//  Onboarding.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/12/25.
//

import SwiftUI
import SwiftData

struct Onboarding: View {
    @Environment(\.modelContext) private var context
    
    @State private var restoring: Bool = false
    @State private var showRestoreFailAlert: Bool = false
    
    var body: some View {
        ZStack {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 350, height: 350)
                .opacity(0.9)
                .blur(radius: 400)
            
            VStack() {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 250, height: 250)
                        .opacity(0.35)
                        .blur(radius: 100)
                    
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 200, height: 200)
                        .opacity(0.475)
                        .blur(radius: 30)
                    
                    Text("SCULPTY")
                        .font(.custom("Oswald-Bold", size: 44))
                        .textColor()
                }
                .padding(.top, 5)
                .padding(.bottom, -10)
                .frame(height: 190)
                
                HStack {
                    VStack(alignment: .leading, spacing: 17) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("YOUR FITNESS JOURNAL")
                                .headingText(size: 24)
                                .textColor()
                            
                            Text("Simple. Powerful. Yours.")
                                .bodyText()
                                .secondaryColor()
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("WORKOUTS")
                                .headingText(size: 18)
                                .textColor()
                            
                            Text("Log your workouts. See your progress.")
                                .bodyText(size: 14)
                                .secondaryColor()
                                .padding(.leading, 10)
                                .multilineTextAlignment(.leading)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("CALORIES")
                                .headingText(size: 18)
                                .textColor()
                            
                            Text("Monitor your daily intake and macros.")
                                .bodyText(size: 14)
                                .secondaryColor()
                                .padding(.leading, 10)
                                .multilineTextAlignment(.leading)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("MEASUREMENTS")
                                .headingText(size: 18)
                                .textColor()
                            
                            Text("Record body measurements. Visualize your progress.")
                                .bodyText(size: 14)
                                .secondaryColor()
                                .padding(.leading, 10)
                                .multilineTextAlignment(.leading)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("STATS")
                                .headingText(size: 18)
                                .textColor()
                            
                            Text("View trends and insights based on your recorded data.")
                                .bodyText(size: 14)
                                .secondaryColor()
                                .padding(.leading, 10)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        VStack (alignment: .leading, spacing: 10){
                            Text("Your data stays private. No recommendations. No ads. Just tools.")
                                .bodyText(size: 14)
                                .secondaryColor()
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button {
                                preloadData()
                                
                                withAnimation {
                                    UserDefaults.standard.set(true, forKey: UserKeys.onboarded.rawValue)
                                }
                            } label: {
                                Text("GET STARTED")
                                    .bodyText()
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(FilledToBorderedButtonStyle())
                            
                            Button {
                                restoring = true
                            } label: {
                                Text("RESTORE FROM BACKUP")
                                    .bodyText()
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(BorderedToFilledButtonStyle())
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 25)
                .padding(.bottom)
                .padding(.horizontal)
                .fileImporter(
                    isPresented: $restoring,
                    allowedContentTypes: [.json],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else { return }
                        
                        guard url.startAccessingSecurityScopedResource() else {
                            showRestoreFailAlert = true
                            return
                        }
                        
                        guard let importedData = try? Data(contentsOf: url) else {
                            showRestoreFailAlert = true
                            return
                        }
                        
                        url.stopAccessingSecurityScopedResource()
                        
                        let decoder = JSONDecoder()
                        
                        guard let data = try? decoder.decode(ExportData.self, from: importedData) else {
                            showRestoreFailAlert = true
                            return
                        }
                        
                        DispatchQueue.main.async {
                            for exercise in data.exercises {
                                guard !exercise.name.isEmpty && exercise.muscleGroup != nil else { continue }
                                if exercise.notes.isEmpty { exercise.notes = "" }
                                
                                context.insert(Exercise(name: exercise.name, notes: exercise.notes, muscleGroup: exercise.muscleGroup ?? .other, type: exercise.type))
                            }
                            
                            var importedWorkouts: [Workout] = []
                            
                            for workout in data.workouts {
                                var exercises: [WorkoutExercise] = []
                                for workoutExercise in workout.exercises {
                                    let exercise: Exercise = workoutExercise.exercise!
                                    
                                    let newExercise = Exercise(name: exercise.name, notes: exercise.notes, muscleGroup: exercise.muscleGroup ?? .other)
                                    workoutExercise.exercise = newExercise
                                    context.insert(newExercise)
                                    
                                    exercises.append(workoutExercise)
                                }
                                
                                let newWorkout = Workout(name: workout.name, exercises: [], notes: workout.notes)
                                for workoutExercise in exercises {
                                    workoutExercise.workout = newWorkout
                                }
                                
                                context.insert(newWorkout)
                                
                                do {
                                    try context.save()
                                } catch {
                                    print("Failed to save workout: \(error.localizedDescription)")
                                }
                                
                                importedWorkouts.append(newWorkout)
                                context.insert(WorkoutLog(workout: newWorkout))
                            }

                            do {
                                try context.save()
                            } catch {
                                print("Failed to save imported data: \(error.localizedDescription)")
                            }
                            
                            for log in data.workoutLogs {
                                if let workout = importedWorkouts.first(where: { $0.name == log.workout.name }) {
                                    let newLog = WorkoutLog(workout: workout, started: log.started, completed: log.completed, start: log.start, end: log.end)
                                    
                                    for exerciseLog in log.exerciseLogs {
                                        if let exercise = workout.exercises.first(where: { $0.exercise?.name == exerciseLog.exercise.exercise?.name }) {
                                            let newExerciseLog = ExerciseLog(index: exerciseLog.index, exercise: exercise)
                                            newLog.exerciseLogs.append(newExerciseLog)
                                        } else {
                                            print("Error: Exercise not found for ExerciseLog")
                                        }
                                    }
                                    
                                    context.insert(newLog)
                                } else {
                                    print("Error: Workout not found for WorkoutLog")
                                }
                            }
                            
                            for log in data.caloriesLogs {
                                let log = CaloriesLog(from: log)
                                
                                guard !log.entries.isEmpty && log.date.timeIntervalSince1970 != 0 else { continue }
                                
                                var entries: [FoodEntry] = []
                                for entry in log.entries {
                                    guard !entry.name.isEmpty && entry.calories >= 0 && entry.carbs >= 0 && entry.protein >= 0 && entry.fat >= 0 else { continue }
                                    
                                    entries.append(FoodEntry(name: entry.name, calories: entry.calories, carbs: entry.carbs, protein: entry.protein, fat: entry.fat))
                                }
                                
                                context.insert(CaloriesLog(date: log.date, entries: entries))
                            }
                            
                            do {
                                try context.save()
                                
                                withAnimation {
                                    UserDefaults.standard.set(true, forKey: UserKeys.onboarded.rawValue)
                                }
                            } catch {
                                print("Failed to save imported data: \(error.localizedDescription)")
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    showRestoreFailAlert = true
                                }
                            }
                        }
                        
                        restoring = false
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .alert(isPresented: $showRestoreFailAlert) {
                    Alert(title: Text("Error"),
                          message: Text("There was an error when attempting to restore your data. Please make sure that you are uploading the correct file. You may need to try again later or report an issue."))
                }
            }
        }
    }
    
    private func preloadData() {
        if let existingExercises = try? context.fetch(FetchDescriptor<Exercise>()), existingExercises.isEmpty {
            for exercise in defaultExercises {
                context.insert(exercise)
            }
            
            do {
                try context.save()
            } catch {
                print("Error preloading data: \(error)")
            }
        }
    }
}

#Preview {
    Onboarding()
}
