//
//  CaloriesLoggedWidget.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI
import WidgetKit

struct CaloriesLoggedWidget: Widget {
    let kind: String = "CaloriesLoggedWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaloriesLoggedProvider()) { entry in
            CaloriesLoggedWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Calories Logged")
        .description("See how many calories you've logged today")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
