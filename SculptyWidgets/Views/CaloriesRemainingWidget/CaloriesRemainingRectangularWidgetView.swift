//
//  CaloriesRemainingRectangularWidgetView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesRemainingRectangularWidgetView: View {
    let entry: CaloriesRemainingEntry
    
    var body: some View {
        HStack(alignment: .center, spacing: .spacingS) {
            Image(systemName: "target")
                .headingText(weight: .medium)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Remaining")
                    .captionText()
                
                Text("\(entry.caloriesRemaining)cal")
                    .bodyText()
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
        }
    }
}
