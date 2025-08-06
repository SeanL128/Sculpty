//
//  CaloriesLoggedRectangularWidgetView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesLoggedRectangularWidgetView: View {
    let entry: CaloriesLoggedEntry
    
    var body: some View {
        HStack(alignment: .center, spacing: .spacingS) {
            Image(systemName: "fork.knife")
                .headingText(weight: .medium)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Logged")
                    .captionText()
                
                Text("\(entry.caloriesLogged)cal")
                    .bodyText()
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
        }
    }
}
