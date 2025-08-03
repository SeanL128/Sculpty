//
//  OptionsStatsSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsStatsSection: View {
    @EnvironmentObject private var settings: CloudSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "Stats", image: "chart.xyaxis.line")
            
            VStack(alignment: .leading, spacing: .spacingS) {
                OptionsToggleRow(
                    text: "Include Warm Up Sets",
                    isOn: $settings.includeWarmUp
                )
                
                OptionsToggleRow(
                    text: "Include Drop Sets",
                    isOn: $settings.includeDropSet
                )
                
                OptionsToggleRow(
                    text: "Include Cool Down Sets",
                    isOn: $settings.includeCoolDown
                )
            }
            .card()
        }
        .frame(maxWidth: .infinity)
    }
}
