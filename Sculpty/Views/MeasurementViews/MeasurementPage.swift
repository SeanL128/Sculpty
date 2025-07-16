//
//  MeasurementPage.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/15/25.
//

import SwiftUI
import SwiftData

struct MeasurementPage: View {
    @Environment(\.modelContext) private var context
    
    var type: MeasurementType
    
    private var unit: String { type.unit }
    
    @State private var data: [Measurement] = []
    
    @State private var confirmDelete: Bool = false
    @State private var measurementToDelete: Measurement?
    
    var body: some View {
        ContainerView(title: type.rawValue, spacing: 16, lazy: true) {
            if !data.isEmpty {
                ForEach(data, id: \.id) { measurement in
                    MeasurementRow(
                        measurement: measurement,
                        measurementToDelete: $measurementToDelete,
                        confirmDelete: $confirmDelete
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
            } else {
                EmptyState(
                    message: "No Data",
                    size: 18
                )
            }
        }
        .onAppear {
            setData()
        }
        .onChange(of: confirmDelete) {
            if confirmDelete,
               let measurement = measurementToDelete {
                context.delete(measurement)
                
                do {
                    try context.save()
                } catch {
                    debugLog("Error: \(error.localizedDescription)")
                }
                
                setData()
                
                confirmDelete = false
                measurementToDelete = nil
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: data.count)
    }
    
    private func setData() {
        do {
            let fetched = try context.fetch(FetchDescriptor<Measurement>())
                .filter({ $0.type == type })
                .sorted(by: { $0.date > $1.date })
            
            data = fetched
        } catch {
            debugLog(error.localizedDescription)
            
            data = []
        }
    }
}
