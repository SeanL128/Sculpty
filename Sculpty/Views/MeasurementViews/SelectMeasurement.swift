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
        ContainerView(title: "Select Measurement", spacing: 16) {
            ForEach(MeasurementType.displayOrder, id: \.id) { type in
                Button {
                    selectedMeasurementType = type
                } label: {
                    HStack(alignment: .center) {
                        Text(type.rawValue)
                            .bodyText(size: 16, weight: selectedMeasurementType == type ? .bold : .regular)
                            .multilineTextAlignment(.leading)
                            .animation(.easeInOut(duration: 0.2), value: selectedMeasurementType == type)
                        
                        if measurementOptions.contains(where: { $0 == type }) {
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 10, weight: selectedMeasurementType == type ? .bold : .regular))
                                .animation(.easeInOut(duration: 0.2), value: selectedMeasurementType == type)
                        }
                        
                        if selectedMeasurementType == type {
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .padding(.horizontal, 8)
                                .font(Font.system(size: 16))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .foregroundStyle(forStats && !measurementOptions.contains(where: { $0 == type }) ? ColorManager.secondary : ColorManager.text) // swiftlint:disable:this line_length
                .disabled(forStats && !measurementOptions.contains(where: { $0 == type }))
                .animatedButton(scale: 0.98, isValid: !forStats || measurementOptions.contains(where: { $0 == type }))
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .onChange(of: selectedMeasurementType) {
            if selectedMeasurementType != nil {
                dismiss()
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMeasurementType)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: measurementOptions.count)
    }
}
