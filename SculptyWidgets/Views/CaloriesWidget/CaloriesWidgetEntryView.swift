//
//  CaloriesWidgetEntryView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: CaloriesProvider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            CaloriesSmallWidgetView(entry: entry)
        case .systemMedium:
            CaloriesMediumWidgetView(entry: entry)
        default:
            CaloriesSmallWidgetView(entry: entry)
        }
    }
}
