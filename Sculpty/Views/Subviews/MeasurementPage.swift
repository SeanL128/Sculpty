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
    
    private var unit: String {
        switch type {
        case .bodyFat: return "%"
        case .weight: return UnitsManager.weight
        default: return UnitsManager.shortLength
        }
    }
    
    @State private var data: [Measurement] = []
    
    @State private var confirmDelete: Bool = false
    @State private var measurementToDelete: Measurement? = nil
    
    var body: some View {
        ContainerView(title: type.rawValue) {
            if data.isEmpty {
                Text("No Data")
                    .bodyText(size: 18)
                    .textColor()
            } else {
                ForEach(data, id: \.id) { measurement in
                    HStack(alignment: .center) {
                        Text("\(formatDateWithTime(measurement.date))  -  \(measurement.measurement.formatted())\(measurement.unit)")
                            .bodyText(size: 16)
                        
                        Spacer()
                        
                        Button {
                            measurementToDelete = measurement
                            
                            Task {
                                await ConfirmationPopup(selection: $confirmDelete, promptText: "Delete measurement from \(formatDateWithTime(measurement.date))?", cancelText: "Cancel", confirmText: "Delete").present()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .padding(.horizontal, 8)
                                .font(Font.system(size: 16))
                        }
                        .textColor()
                        .onChange(of: confirmDelete) {
                            if confirmDelete,
                               let measurement = measurementToDelete {
                                context.delete(measurement)
                                try? context.save()
                                
                                setData()
                                
                                confirmDelete = false
                                measurementToDelete = nil
                            }
                        }
                    }
                    .textColor()
                }
            }
        }
        .onAppear() {
            setData()
        }
    }
    
    private func setData() {
        do {
            let fetched = try context.fetch(FetchDescriptor<Measurement>()).filter({ $0.type == type }).sorted(by: { $0.date > $1.date })
            
            data = fetched
        } catch {
            debugLog(error.localizedDescription)
            
            data = []
        }
    }
}
