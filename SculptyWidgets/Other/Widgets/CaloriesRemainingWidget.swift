//
//  CaloriesRemainingWidget.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI
import WidgetKit

struct CaloriesRemainingWidget: Widget {
    let kind: String = "CaloriesRemainingWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaloriesRemainingProvider()) { entry in
            CaloriesRemainingWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Calories Remaining")
        .description("See how many calories you have left today")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
