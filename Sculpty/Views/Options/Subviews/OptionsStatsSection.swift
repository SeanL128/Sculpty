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
        VStack(alignment: .leading, spacing: 12) {
            OptionsSectionHeader(title: "Stats", image: "chart.xyaxis.line")
            
            OptionsToggleRow(
                title: "Include Warm Up Sets",
                isOn: $settings.includeWarmUp
            )
            
            OptionsToggleRow(
                title: "Include Drop Sets",
                isOn: $settings.includeDropSet
            )
            
            OptionsToggleRow(
                title: "Include Cool Down Sets",
                isOn: $settings.includeCoolDown
            )
        }
        .frame(maxWidth: .infinity)
    }
}
