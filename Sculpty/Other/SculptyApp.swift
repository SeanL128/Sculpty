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
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var settings = CloudSettings()
    
    var colorScheme: ColorScheme? {
        switch settings.appearance {
        case .light:
            return .light
        case .dark:
            return .dark
        case .automatic:
            return nil
        }
    }
    
    init() {
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
    
    var body: some Scene {
        WindowGroup {
            Main()
                .preferredColorScheme(colorScheme)
                .accentColor(Color(hex: settings.accentColorHex))
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
