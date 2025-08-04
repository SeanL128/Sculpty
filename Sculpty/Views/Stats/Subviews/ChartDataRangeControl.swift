//
//  ChartDataRangeControl.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct ChartDateRangeControl: View {
    @Binding var selectedRangeIndex: Int
    
    var body: some View {
        TypedSegmentedControl(
            selection: $selectedRangeIndex,
            options: [0, 1, 2, 3, 4],
            displayNames: ["Last 7 Days", "Last 30 Days", "Last 6 Months", "Last Year", "Last 5 Years"],
            animate: false
        )
        .padding(.bottom, -.spacingS)
    }
}
