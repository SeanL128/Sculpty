//
//  SculptyApp.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData
import UserNotifications
import IQKeyboardManagerSwift

@main
struct SculptyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var settings = CloudSettings()
    
    init() {
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
    
    var modelContainer: ModelContainer = {
        let schema = Schema([
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Exercise.self,
            WorkoutLog.self,
            ExerciseLog.self,
            SetLog.self,
            CaloriesLog.self,
            FoodEntry.self,
            Measurement.self,
            CustomFood.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            Main()
                .preferredColorScheme(.dark)
                .accentColor(Color(hex: settings.accentColorHex))
                .dynamicTypeSize(.medium ... .xxxLarge)
                .modelContainer(modelContainer)
                .environmentObject(settings)
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        UNUserNotificationCenter.current().setBadgeCount(0)
                    }
                }
        }
    }
}
