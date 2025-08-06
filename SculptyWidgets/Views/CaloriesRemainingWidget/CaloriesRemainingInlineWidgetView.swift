//
//  CaloriesRemainingInlineWidgetView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesRemainingInlineWidgetView: View {
    let entry: CaloriesRemainingEntry
    
    var body: some View {
        HStack(spacing: .spacingXS) {
            Image(systemName: "target")
                .secondaryText()
            
            Text("\(entry.caloriesRemaining)cal logged")
                .secondaryText(weight: .medium)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}
