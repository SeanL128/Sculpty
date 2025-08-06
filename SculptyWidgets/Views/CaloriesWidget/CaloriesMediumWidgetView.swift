//
//  CaloriesMediumWidgetView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesMediumWidgetView: View {
    let entry: CaloriesEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "fork.knife")
                .headingText(weight: .medium)
                .textColor()
            
            Spacer()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(entry.totalCalories)cal")
                        .subheadingText(weight: .medium)
                        .textColor()
                        .monospacedDigit()
                    
                    Text("Target: \(entry.targetCalories)cal")
                        .secondaryText()
                        .secondaryColor()
                        .monospacedDigit()
                    
                    Text("\(entry.remainingCalories)cal remaining")
                        .secondaryText(weight: .light)
                        .secondaryColor()
                        .monospacedDigit()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: .spacingXS) {
                    MacroLabel(
                        value: entry.carbs,
                        label: "Carbs",
                        color: Color.blue
                    )
                    .captionText()
                    
                    MacroLabel(
                        value: entry.protein,
                        label: "Protein",
                        color: Color.red
                    )
                    .captionText()
                    
                    MacroLabel(
                        value: entry.fat,
                        label: "Fat",
                        color: Color.orange
                    )
                    .captionText()
                }
            }
        }
        .padding(.spacingXS)
    }
}
