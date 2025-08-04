//
//  MeasurementRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct MeasurementRow: View {
    let measurement: Measurement
    
    @Binding var measurementToDelete: Measurement?
    @Binding var confirmDelete: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            Text("\(formatDateWithTime(measurement.date)) - \(measurement.measurement.formatted())\(measurement.unit)") // swiftlint:disable:this line_length
                .bodyText(weight: .regular)
                .textColor()
                .multilineTextAlignment(.leading)
                .monospacedDigit()
            
            Spacer()
            
            Button {
                measurementToDelete = measurement
                
                Popup.show(content: {
                    ConfirmationPopup(
                        selection: $confirmDelete,
                        promptText: "Delete measurement from \(formatDateWithTime(measurement.date))?",
                        cancelText: "Cancel",
                        confirmText: "Delete"
                    )
                })
            } label: {
                Image(systemName: "xmark")
                    .bodyText(weight: .regular)
            }
            .textColor()
            .animatedButton(feedback: .warning)
        }
        .frame(maxWidth: .infinity)
    }
}
