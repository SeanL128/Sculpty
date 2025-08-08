//
//  OptionsCustomizationSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/16/25.
//

import SwiftUI

struct OptionsCustomizationSection: View {
    @EnvironmentObject private var settings: CloudSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "Customization", image: "paintbrush.pointed.fill")
            
            VStack(alignment: .leading, spacing: .listSpacing) {
                HStack {
                    Text("Accent Color")
                        .bodyText()
                    
                    Spacer()
                    
                    Button {
                        Popup.show(content: {
                            AccentColorMenuPopup(selection: $settings.accentColorHex)
                        })
                    } label: {
                        HStack(alignment: .center, spacing: .spacingS) {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 10, height: 10)
                            
                            HStack(alignment: .center, spacing: .spacingXS) {
                                if let accent = AccentColor.fromHex(settings.accentColorHex) {
                                    Text(accent.rawValue)
                                        .bodyText()
                                }
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .captionText(weight: .bold)
                            }
                        }
                    }
                    .textColor()
                    .animatedButton(feedback: .selection)
                }
                
                OptionsToggleRow(
                    text: "Enable Haptics",
                    isOn: $settings.enableHaptics
                )
                
                OptionsToggleRow(
                    text: "Enable Toasts",
                    isOn: $settings.enableToasts
                )
                
                OptionsToggleRow(
                    text: "Enable Live Activities",
                    isOn: $settings.enableLiveActivities
                )
            }
            .card()
        }
        .frame(maxWidth: .infinity)
    }
}
