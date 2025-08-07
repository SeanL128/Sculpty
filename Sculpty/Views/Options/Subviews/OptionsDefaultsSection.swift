//
//  OptionsDefaultsSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsDefaultsSection: View {
    @EnvironmentObject private var settings: CloudSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "Defaults", image: "doc.plaintext")
            
            VStack(alignment: .leading, spacing: .listSpacing) {
                OptionsPickerRow(
                    title: "Units",
                    text: settings.units == "Imperial" ? "Imperial (mi, ft, in, lbs)" : "Metric (km, m, cm, kg)",
                    popup: UnitMenuPopup(selection: $settings.units)
                )
            }
            .card()
        }
        .frame(maxWidth: .infinity)
    }
}
