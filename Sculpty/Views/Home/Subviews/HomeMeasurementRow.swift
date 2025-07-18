//
//  HomeMeasurementRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct HomeMeasusrementRow: View {
    let measurement: Measurement
    let large: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("\(measurement.type.rawValue) (")
                    .bodyText(size: large ? 18 : 14)
                    .textColor()
                
                Text("\(measurement.measurement.formatted())\(measurement.unit)")
                    .statsText(size: large ? 18 : 14)
                    .textColor()
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: measurement.measurement)
                
                Text(")")
                    .bodyText(size: large ? 18 : 14)
                    .textColor()
            }
            
            Text(formatDateWithTime(measurement.date))
                .bodyText(size: large ? 12 : 10)
                .secondaryColor()
        }
    }
}
