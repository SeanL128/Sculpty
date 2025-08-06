//
//  CaloriesSmallWidgetView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesSmallWidgetView: View {
    let entry: CaloriesEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "fork.knife")
                .headingText(weight: .medium)
                .textColor()
            
            Spacer()
            
            VStack(alignment: .leading, spacing: .spacingXS) {
                Text("\(entry.totalCalories)cal")
                    .subheadingText(weight: .medium)
                    .textColor()
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("Target: \(entry.targetCalories)cal")
                    .secondaryText()
                    .secondaryColor()
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(entry.remainingCalories)cal remaining")
                    .secondaryText(weight: .light)
                    .secondaryColor()
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.spacingXS)
    }
}
