//
//  CaloriesLoggedCircularWidgetView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesLoggedCircularWidgetView: View {
    let entry: CaloriesLoggedEntry
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "fork.knife")
                .bodyText()
            
            Text("\(entry.caloriesLogged)")
                .bodyText(weight: .bold)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}
