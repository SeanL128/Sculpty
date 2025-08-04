//
//  HomeMeasurementRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct HomeMeasusrementRow: View {
    let measurement: Measurement
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(measurement.type.rawValue) (\(measurement.measurement.formatted())\(measurement.unit))")
                    .bodyText(weight: .regular)
                    .monospacedDigit()
                    .textColor()
                
                Text(formatDateWithTime(measurement.date))
                    .captionText()
                    .secondaryColor()
            }
            
            Spacer()
        }
    }
}
