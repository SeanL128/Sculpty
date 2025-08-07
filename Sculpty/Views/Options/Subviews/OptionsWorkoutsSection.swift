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
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "Workouts", image: "dumbbell")
            
            VStack(alignment: .leading, spacing: .listSpacing) {
                OptionsInputRow(
                    title: "Weekly Workouts Goal",
                    unit: "",
                    text: $settings.targetWeeklyWorkoutsString
                )
                
                OptionsToggleRow(
                    text: "Enable RIR",
                    isOn: $settings.showRir
                )
                
                OptionsToggleRow(
                    text: "Enable 1RM",
                    isOn: $settings.show1RM
                )
                
                OptionsToggleRow(
                    text: "Enable Tempo",
                    isOn: $settings.showTempo
                )
                
                OptionsToggleRow(
                    text: "Enable Set Timers",
                    isOn: $settings.showSetTimer
                )
            }
            .card()
        }
        .frame(maxWidth: .infinity)
    }
}
