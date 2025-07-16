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
            Text("\(formatDateWithTime(measurement.date))  -  \(measurement.measurement.formatted())\(measurement.unit)") // swiftlint:disable:this line_length
                .bodyText(size: 16)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: measurement.measurement)
            
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
                    .padding(.horizontal, 8)
                    .font(Font.system(size: 16))
            }
            .textColor()
            .animatedButton(feedback: .warning)
        }
        .textColor()
        .transition(.asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }
}
