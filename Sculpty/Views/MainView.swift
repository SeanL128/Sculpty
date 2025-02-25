////
////  MainView.swift
////  Sculpty
////
////  Created by Sean Lindsay on 1/12/25.
////
//
//import SwiftUI
//import SwiftData
//
//struct MainView: View {
//    @Environment(\.modelContext) private var context
//    
//    @Query private var workouts: [Workout]
//    
//    @State private var selectedTab: Int = 0
//    
//    @State private var showViewWorkout = false
//    @State private var selectedWorkout: Workout?
//    @State private var selectedLog: WorkoutLog?
//    
//    @AppStorage(UserKeys.onboarded.rawValue) private var onboarded = false
//    
//    var body: some View {
//        ZStack {
//            ColorManager.background
//                .ignoresSafeArea(edges: .all)
//
//            if !onboarded {
//                Onboarding()
//                    .transition(.opacity)
//            } else if showViewWorkout, let workout = selectedWorkout, let log = selectedLog {
//                ViewWorkout(workout: workout, workoutLog: log) {
//                    showViewWorkout = false
//                }
//                .transition(.move(edge: .trailing))
//            } else {
//                NavigationStack {
//                    TabView (selection: $selectedTab) {
//                        WorkoutList { workout, log in
//                            selectedWorkout = workout
//                            selectedLog = log
//                            showViewWorkout = true
//                        }
//                        .tabItem { Label("Workouts", systemImage: "figure.run") }
//                        .tag(0)
//                        
//                        Stats(selectedTab: $selectedTab, tabTag: 1)
//                            .tabItem { Label("Stats", systemImage: "chart.xyaxis.line") }
//                            .tag(1)
//                        
//                        Calories(selectedTab: $selectedTab, tabTag: 2)
//                            .tabItem { Label("Calories", systemImage: "fork.knife") }
//                            .tag(2)
//                        
//                        Measurements()
//                            .tabItem { Label("Measurements", systemImage: "ruler")}
//                            .tag(3)
//                        
//                        Options(selectedTab: $selectedTab, tabTag: 4)
//                            .tabItem { Label("Options", systemImage: "gearshape.fill") }
//                            .tag(4)
//                    }
//                }
//                .onAppear(perform: initLogs)
//                .transition(.move(edge: .leading))
//            }
//        }
//        .onAppear(perform: cleanupInvalidWorkouts)
//    }
//    
//    private func cleanupInvalidWorkouts() {
//        let invalidWorkouts = workouts.filter { $0.index < 0 }
//        
//        if !invalidWorkouts.isEmpty {
//            for workout in invalidWorkouts {
//                workout.exercises.forEach { context.delete($0) }
//                context.delete(workout)
//            }
//            
//            try? context.save()
//        }
//    }
//
//    private func initLogs() {
//        let today = Calendar.current.startOfDay(for: Date())
//        let lastChecked = UserDefaults.standard.object(forKey: UserKeys.lastCheckedDate.rawValue) as? Date
//        
//        guard lastChecked == nil || !Calendar.current.isDate(lastChecked!, inSameDayAs: today) else { return }
//        
//        UserDefaults.standard.set(today, forKey: UserKeys.lastCheckedDate.rawValue)
//        
//        do {
//            let workoutLogs: [WorkoutLog] = try context.fetch(FetchDescriptor<WorkoutLog>())
//            let caloriesLogs: [CaloriesLog] = try context.fetch(FetchDescriptor<CaloriesLog>())
//            
//            workoutLogs
//                .filter { !$0.started }
//                .forEach { context.delete($0) }
//            
//            caloriesLogs
//                .filter { $0.entries.isEmpty }
//                .forEach { context.delete($0) }
//            
//            if workoutLogs.allSatisfy({ !Calendar.current.isDate($0.start, inSameDayAs: today) }) {
//                workouts.forEach { context.insert(WorkoutLog(workout: $0)) }
//            }
//            
//            if caloriesLogs.allSatisfy({ !Calendar.current.isDate($0.date, inSameDayAs: today) }) {
//                context.insert(CaloriesLog())
//            }
//            
//            try context.save()
//        } catch {
//            print("Error fetching logs: \(error.localizedDescription)")
//        }
//    }
//}
//
//#Preview {
//    MainView()
//}
//
//#Preview {
//    MainView()
//}
