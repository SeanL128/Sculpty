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
            
            VStack(alignment: .leading, spacing: .spacingS) {
                HStack {
                    Text("Accent Color")
                        .bodyText()
                    
                    Spacer()
                    
                    Button {
                        Popup.show(content: {
                            AccentColorMenuPopup(selection: $settings.accentColorHex)
                        })
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            Circle()
                                .fill(Color(hex: settings.accentColorHex))
                                .frame(width: 10, height: 10)
                            
                            if let accent = AccentColor.fromHex(settings.accentColorHex) {
                                Text(accent.rawValue)
                                    .bodyText()
                            }
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .captionText(weight: .bold)
                        }
                    }
                    .textColor()
                    .animatedButton(feedback: .selection)
                }
            }
            .card()
        }
        .frame(maxWidth: .infinity)
    }
}
