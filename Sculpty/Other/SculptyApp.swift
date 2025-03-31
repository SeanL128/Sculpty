//
//  SculptyApp.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData
import MijickPopups

@main
struct SculptyApp: App {
    @AppStorage(UserKeys.appearance.rawValue) private var selectedAppearance: Appearance = .automatic
    var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case .light:
            return .light
        case .dark:
            return .dark
        case .automatic:
            return nil
        }
    }
    
    @AppStorage(UserKeys.accent.rawValue) private var accentColorHex: String = "#C50A2B"
    
    var body: some Scene {
        WindowGroup {
            Home()
                .preferredColorScheme(colorScheme)
                .accentColor(Color(hex: accentColorHex))
                .dynamicTypeSize(.medium ... .xxxLarge)
                .modelContainer(for: [Workout.self, Exercise.self, WorkoutLog.self, CaloriesLog.self, Measurement.self])
                .registerPopups(id: .shared) { config in config
                    .vertical { $0
                        .enableDragGesture(true)
                        .tapOutsideToDismissPopup(true)
                        .cornerRadius(15)
                        .popupTopPadding(10)
                    }
                    .center { $0
                        .tapOutsideToDismissPopup(true)
                        .backgroundColor(ColorManager.background)
                        .cornerRadius(15)
                        .popupHorizontalPadding(5)
                    }
                }
        }
    }
}
