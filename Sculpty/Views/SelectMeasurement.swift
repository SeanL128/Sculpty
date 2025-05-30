//
//  SelectMeasurement.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/27/25.
//

import SwiftUI
import SwiftData

struct SelectMeasurement: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var measurements: [Measurement]
    private var measurementOptions: [MeasurementType] {
        if forStats {
            return MeasurementType.displayOrder.filter { type in
                measurements.contains(where: { $0.type == type })
            }
        } else {
            return MeasurementType.displayOrder
        }
    }
    
    @Binding var selectedMeasurementType: MeasurementType?
    
    var forStats: Bool = false
    
    var body: some View {
        ContainerView(title: "Select Measurement", spacing: 16, showScrollBar: true) {
            ForEach(MeasurementType.displayOrder, id: \.id) { type in
                Button {
                    selectedMeasurementType = type
                } label: {
                    HStack(alignment: .center) {
                        Text(type.rawValue)
                            .bodyText(size: 16, weight: selectedMeasurementType == type ? .bold : .regular)
                            .multilineTextAlignment(.leading)
                        
                        if measurementOptions.contains(where: { $0 == type }) {
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 10, weight: selectedMeasurementType == type ? .bold : .regular))
                        }
                        
                        if selectedMeasurementType == type {
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .padding(.horizontal, 8)
                                .font(Font.system(size: 16))
                        }
                    }
                }
                .foregroundStyle(forStats && !measurementOptions.contains(where: { $0 == type }) ? ColorManager.secondary : ColorManager.text)
                .disabled(forStats && !measurementOptions.contains(where: { $0 == type }))
            }
        }
        .onChange(of: selectedMeasurementType) {
            if selectedMeasurementType != nil {
                dismiss()
            }
        }
    }
}
