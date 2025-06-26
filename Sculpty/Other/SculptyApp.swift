//
//  SculptyApp.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct SculptyApp: App {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var settings = CloudSettings()
    
    var body: some Scene {
        WindowGroup {
            Main()
                .accentColor(Color("AccentColor"))
                .dynamicTypeSize(.medium ... .xxxLarge)
                .modelContainer(for: [Workout.self, Exercise.self, WorkoutLog.self, CaloriesLog.self, Measurement.self])
                .environmentObject(settings)
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        UNUserNotificationCenter.current().setBadgeCount(0)
                    }
                }
        }
    }
}
