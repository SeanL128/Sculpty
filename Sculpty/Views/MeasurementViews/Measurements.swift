//
//  Measurements.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/11/25.
//

import SwiftUI
import SwiftData

struct Measurements: View {
    @Query private var measurements: [Measurement]
    
    var body: some View {
        ContainerView(title: "Measurements", spacing: .listSpacing, lazy: true) {
            ForEach(MeasurementType.displayOrder, id: \.id) { type in
                let empty = measurements.filter { $0.type == type }.isEmpty
                
                NavigationLink {
                    MeasurementPage(type: type)
                } label: {
                    HStack(alignment: .center, spacing: .spacingXS) {
                        Text(type.rawValue)
                            .bodyText(weight: .regular)
                            .multilineTextAlignment(.leading)
                        
                        if !empty {
                            Image(systemName: "chevron.right")
                                .bodyImage()
                        }
                    }
                }
                .foregroundStyle(!empty ? ColorManager.text : ColorManager.secondary)
                .disabled(empty)
                .animatedButton(feedback: .selection, isValid: !empty)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .leading)),
                    removal: .opacity.combined(with: .move(edge: .trailing))
                ))
            }
        }
    }
}
