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
                .animatedButton()
            }
            .card()
        }
        .frame(maxWidth: .infinity)
    }
}
