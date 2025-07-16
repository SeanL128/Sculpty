//
//  OptionsCustomizationSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/16/25.
//

import SwiftUI

struct OptionsCustomizationSection: View {
    @EnvironmentObject private var settings: CloudSettings
    
    private var appearanceText: String {
        switch settings.appearance {
        case .automatic: return "Automatic"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            OptionsSectionHeader(title: "Customization", image: "paintbrush.pointed.fill")
            
            OptionsPickerRow(
                title: "Appearance",
                text: appearanceText,
                popup: AppearanceMenuPopup(selection: $settings.appearance)
            )
            
            HStack {
                Text("Accent Color")
                    .bodyText(size: 18)
                
                Spacer()
                
                Button {
                    Popup.show(content: {
                        AccentColorMenuPopup(selection: $settings.accentColorHex)
                    })
                } label: {
                    HStack(alignment: .center) {
                        Circle()
                            .fill(Color(hex: settings.accentColorHex))
                            .frame(width: 10, height: 10)
                        
                        if let accent = AccentColor.fromHex(settings.accentColorHex) {
                            Text(accent.rawValue)
                                .bodyText(size: 18, weight: .bold)
                        }
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .font(Font.system(size: 12, weight: .bold))
                    }
                }
                .textColor()
                .animatedButton(scale: 0.98)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
