//
//  HomeMeasurementSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI
import SwiftData

struct HomeMeasurementSection: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: [SortDescriptor(\Measurement.date, order: .reverse)]) private var measurements: [Measurement]
    
    @State private var measurementToAdd: Measurement?
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingS) {
            HomeSectionHeader(icon: "ruler", title: "Measurements") {
                NavigationLink {
                    MeasurementStats()
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                        .headingImage()
                }
                .animatedButton(feedback: .selection)
                
                Button {
                    Popup.show(content: {
                        AddMeasurementPopup(measurementToAdd: $measurementToAdd)
                    })
                } label: {
                    Image(systemName: "plus")
                        .headingImage()
                }
                .animatedButton()
            }
            
            VStack(alignment: .center, spacing: .spacingS) {
                if !measurements.isEmpty {
                    ForEach(Array(measurements.prefix(3)), id: \.id) { measurement in
                        HomeMeasusrementRow(measurement: measurement)
                    }
                } else {
                    VStack(alignment: .center, spacing: .spacingXS) {
                        Text("Ready to track your measurements")
                            .bodyText(weight: .bold)
                        
                        Text("Click the + to get started")
                            .secondaryText()
                    }
                    .textColor()
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
                }
            }
            .card()
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: measurements.count)
        }
        .onChange(of: measurementToAdd) {
            if let measurement = measurementToAdd {
                context.insert(measurement)
                
                do {
                    try context.save()
                } catch {
                    debugLog("Error: \(error.localizedDescription)")
                }
                
                measurementToAdd = nil
            }
        }
    }
}
