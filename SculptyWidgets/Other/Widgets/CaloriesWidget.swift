//
//  CaloriesWidget.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI
import WidgetKit

struct CaloriesWidget: Widget {
    let kind: String = "CaloriesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaloriesProvider()) { entry in
            CaloriesWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    ColorManager.background
                }
        }
        .configurationDisplayName("Calories")
        .description("Track your daily calorie intake and macros")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
