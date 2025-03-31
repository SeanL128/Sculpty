//
//  OnboardingSlide6.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/10/25.
//

import SwiftUI
import SwiftData

struct OnboardingSlide6: View {
    @Environment(\.modelContext) var context
    
    @State private var restoring: Bool = false
    @State private var showRestoreFailAlert: Bool = false
    
    @Binding var selectedTab: Int
    var lastTab: Int
    
    var body: some View {
        ZStack {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            VStack {
                Spacer()
                
                VStack {
                    Button {
                        preloadData()
                        
                        withAnimation {
                            UserDefaults.standard.set(true, forKey: UserKeys.onboarded.rawValue)
                        }
                    } label: {
                        Text("New? Get Started")
                        Image(systemName: "chevron.right")
                    }
                    .padding(.vertical, 10)
                    
                    Button {
                        restoring = true
                    } label: {
                        Text("Returning? Import Backup")
                        Image(systemName: "chevron.right")
                    }
                    .padding(.vertical, 10)
                }
                
                Spacer()
                
                MoveSlideButton(selectedTab: $selectedTab, lastTab: lastTab)
            }
            .padding()
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
                            
                            context.insert(Exercise(name: exercise.name, notes: exercise.notes, muscleGroup: exercise.muscleGroup ?? .other))
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
