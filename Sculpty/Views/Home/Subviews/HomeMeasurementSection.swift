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
        VStack(alignment: .leading, spacing: 8) {
            HomeSectionHeader(icon: "ruler", title: "Measurements") {
                NavigationLink {
                    MeasurementStats()
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 18))
                }
                .animatedButton()
                
                Button {
                    Popup.show(content: {
                        AddMeasurementPopup(measurementToAdd: $measurementToAdd)
                    })
                } label: {
                    Image(systemName: "plus")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 18))
                }
                .animatedButton()
            }
            
            if !measurements.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HomeMeasusrementRow(
                        measurement: measurements.first!, // swiftlint:disable:this force_unwrapping
                        large: true
                    )
                    
                    ForEach(1..<min(measurements.count, 3), id: \.self) { index in
                        HomeMeasusrementRow(measurement: measurements[index], large: false)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: measurements.count)
            } else {
                HomeEmptySectionMessage(text: "measurements")
            }
        }
        .frame(maxWidth: .infinity)
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
