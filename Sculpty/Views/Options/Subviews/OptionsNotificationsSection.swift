//
//  OptionsNotificationsSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI
import UIKit

struct OptionsNotificationsSection: View {
    @EnvironmentObject private var settings: CloudSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            OptionsSectionHeader(title: "Notifications", image: "bell")
            
            OptionsToggleRow(
                title: "Enable Notifications",
                isOn: $settings.enableNotifications
            )
            .onChange(of: settings.enableNotifications) {
                if settings.enableNotifications {
                    handleNotificationToggle()
                }
            }
            
            if settings.enableNotifications {
                OptionsToggleRow(
                    title: "Enable Daily Calories Reminders",
                    isOn: $settings.enableCaloriesNotifications
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                
                OptionsToggleRow(
                    title: "Enable Weekly Measurement Reminders",
                    isOn: $settings.enableMeasurementsNotifications
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.3), value: settings.enableNotifications)
    }
    
    private func handleNotificationToggle() {
        NotificationManager.shared.requestPermissionIfNeeded { granted in
            if !granted {
                settings.enableNotifications = false
                
                Popup.show(content: {
                    InfoPopup(
                        title: "Enable Notifications",
                        text: "To receive reminders, please enable notifications in Settings > Sculpty > Notifications"
                    )
                })
                
                openSettings()
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
