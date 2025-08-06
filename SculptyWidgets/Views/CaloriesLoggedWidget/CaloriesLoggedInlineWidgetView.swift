//
//  CaloriesLoggedInlineWidgetView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesLoggedInlineWidgetView: View {
    let entry: CaloriesLoggedEntry
    
    var body: some View {
        HStack(spacing: .spacingXS) {
            Image(systemName: "fork.knife")
                .secondaryText()
            
            Text("\(entry.caloriesLogged)cal logged")
                .secondaryText(weight: .medium)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}
