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
        VStack(alignment: .leading, spacing: 12) {
            OptionsSectionHeader(title: "Calories", image: "fork.knife")
            
            VStack(alignment: .leading) {
                OptionsInputRow(
                    title: "Daily Calories Goal",
                    unit: "cal",
                    text: $settings.dailyCaloriesString
                )
                
                NavigationLink {
                    CalorieCalculator()
                } label: {
                    HStack(alignment: .center) {
                        Text("Not sure? Calculate it here")
                            .bodyText(size: 14, weight: .bold)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 10, weight: .bold))
                    }
                }
                .textColor()
                .animatedButton(scale: 0.98)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
