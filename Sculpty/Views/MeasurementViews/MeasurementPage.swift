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
    
    @State private var loading: Bool = true
    
    @State private var confirmDelete: Bool = false
    @State private var measurementToDelete: Measurement?
    
    var body: some View {
        ContainerView(title: type.rawValue, spacing: .listSpacing, lazy: true) {
            if !data.isEmpty {
                ForEach(data, id: \.id) { measurement in
                    MeasurementRow(
                        measurement: measurement,
                        measurementToDelete: $measurementToDelete,
                        confirmDelete: $confirmDelete
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
                }
                .animation(.easeInOut(duration: 0.4), value: data.count)
            } else if !loading {
                EmptyState(
                    image: "ruler",
                    text: "No \(type.rawValue.lowercased()) measurements logged",
                    subtext: "Log your first measurement"
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: data.isEmpty)
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
    }
    
    private func setData() {
        do {
            let fetched = try context.fetch(FetchDescriptor<Measurement>())
                .filter({ $0.type == type })
                .sorted(by: { $0.date > $1.date })
            
            data = fetched
            
            loading = false
        } catch {
            debugLog(error.localizedDescription)
            
            data = []
        }
    }
}
