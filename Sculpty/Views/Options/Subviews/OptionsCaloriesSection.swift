//
//  OptionsCaloriesSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsCaloriesSection: View {
    @EnvironmentObject private var settings: CloudSettings
    
    @FocusState private var isDailyCaloriesFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "Calories", image: "fork.knife")
            
            VStack(alignment: .leading, spacing: .spacingXS) {
                OptionsInputRow(
                    title: "Daily Calories Goal",
                    unit: "cal",
                    text: $settings.dailyCaloriesString
                )
                .onChange(of: settings.dailyCalories) {
                    guard let sharedDefaults = UserDefaults(suiteName: "group.app.sculpty.SculptyApp") else { return }
                    
                    WidgetDataUpdater.shared.updateWidgetData(
                        caloriesLogged: sharedDefaults.integer(forKey: UserKeys.widgetCaloriesLogged.rawValue),
                        targetCalories: settings.dailyCalories,
                        carbs: sharedDefaults.integer(forKey: UserKeys.widgetCarbs.rawValue),
                        protein: sharedDefaults.integer(forKey: UserKeys.widgetProtein.rawValue),
                        fat: sharedDefaults.integer(forKey: UserKeys.widgetFat.rawValue)
                    )
                }
                
                NavigationLink {
                    CalorieCalculator()
                } label: {
                    HStack(alignment: .center, spacing: .spacingXS) {
                        Text("Not sure? Calculate it here")
                            .secondaryText()
                        
                        Image(systemName: "chevron.right")
                            .secondaryImage()
                    }
                }
                .textColor()
                .animatedButton(feedback: .selection)
            }
            .card()
        }
        .frame(maxWidth: .infinity)
    }
}
