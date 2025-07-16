//
//  OptionsWorkoutsSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsWorkoutsSection: View {
    @EnvironmentObject private var settings: CloudSettings
    
    @FocusState private var isTargetWeeklyWorkoutsFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            OptionsSectionHeader(title: "Workouts", image: "dumbbell")
            
            OptionsInputRow(
                title: "Weekly Workouts Goal",
                unit: "",
                text: $settings.targetWeeklyWorkoutsString
            )
            
            OptionsToggleRow(
                title: "Enable RIR",
                isOn: $settings.showRir
            )
            
            OptionsToggleRow(
                title: "Enable 1RM",
                isOn: $settings.show1RM
            )
            
            OptionsToggleRow(
                title: "Enable Tempo",
                isOn: $settings.showTempo
            )
            
            OptionsToggleRow(
                title: "Enable Set Timers",
                isOn: $settings.showSetTimer
            )
        }
        .frame(maxWidth: .infinity)
    }
}
