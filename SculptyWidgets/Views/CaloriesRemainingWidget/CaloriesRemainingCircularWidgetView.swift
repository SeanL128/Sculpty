//
//  CaloriesRemainingCircularWidgetView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesRemainingCircularWidgetView: View {
    let entry: CaloriesRemainingEntry
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "target")
                .bodyText()
            
            Text("\(entry.caloriesRemaining)")
                .bodyText(weight: .bold)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}
