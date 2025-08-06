//
//  CaloriesRemainingWidgetEntryView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesRemainingWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: CaloriesRemainingEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CaloriesRemainingCircularWidgetView(entry: entry)
        case .accessoryRectangular:
            CaloriesRemainingRectangularWidgetView(entry: entry)
        case .accessoryInline:
            CaloriesRemainingInlineWidgetView(entry: entry)
        default:
            CaloriesRemainingCircularWidgetView(entry: entry)
        }
    }
}
