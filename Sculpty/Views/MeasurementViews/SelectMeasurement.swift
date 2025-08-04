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
        return MeasurementType.displayOrder.filter { type in
            measurements.contains(where: { $0.type == type })
        }
    }
    
    @Binding var selectedMeasurementType: MeasurementType?
    
    var body: some View {
        ContainerView(title: "Measurements", spacing: .listSpacing, lazy: true) {
            ForEach(MeasurementType.displayOrder, id: \.id) { type in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedMeasurementType = type
                    }
                } label: {
                    HStack(alignment: .center, spacing: .spacingXS) {
                        Text(type.rawValue)
                            .bodyText(weight: selectedMeasurementType == type ? .bold : .regular)
                            .multilineTextAlignment(.leading)
                        
                        if measurementOptions.contains(where: { $0 == type }) {
                            Image(systemName: "chevron.right")
                                .bodyImage(weight: selectedMeasurementType == type ? .bold : .medium)
                        }
                        
                        Spacer()
                        
                        if selectedMeasurementType == type {
                            Image(systemName: "checkmark")
                                .bodyText()
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                    removal: .opacity.combined(with: .scale(scale: 0.8))
                                ))
                        }
                    }
                }
                .foregroundStyle(measurementOptions.contains(where: { $0 == type }) ? ColorManager.text : ColorManager.secondary) // swiftlint:disable:this line_length
                .disabled(!measurementOptions.contains(where: { $0 == type }))
                .animatedButton(feedback: .selection, isValid: measurementOptions.contains(where: { $0 == type })) // swiftlint:disable:this line_length
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .leading)),
                    removal: .opacity.combined(with: .move(edge: .trailing))
                ))
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
        .onChange(of: selectedMeasurementType) {
            if selectedMeasurementType != nil {
                dismiss()
            }
        }
    }
}
