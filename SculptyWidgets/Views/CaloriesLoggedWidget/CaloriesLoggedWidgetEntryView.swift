//
//  CaloriesLoggedWidgetEntryView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct CaloriesLoggedWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: CaloriesLoggedEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CaloriesLoggedCircularWidgetView(entry: entry)
        case .accessoryRectangular:
            CaloriesLoggedRectangularWidgetView(entry: entry)
        case .accessoryInline:
            CaloriesLoggedInlineWidgetView(entry: entry)
        default:
            CaloriesLoggedCircularWidgetView(entry: entry)
        }
    }
}
