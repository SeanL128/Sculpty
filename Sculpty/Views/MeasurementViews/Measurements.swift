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
        ContainerView(title: "Measurements", spacing: 16) {
            ForEach(MeasurementType.displayOrder, id: \.id) { type in
                let empty = measurements.filter { $0.type == type }.isEmpty
                
                NavigationLink {
                    MeasurementPage(type: type)
                } label: {
                    HStack(alignment: .center) {
                        Text(type.rawValue)
                            .bodyText(size: 16)
                        
                        if !empty {
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 12))
                        }
                    }
                }
                .disabled(empty)
                .foregroundStyle(empty ? ColorManager.secondary : ColorManager.text)
                .animatedButton(scale: 0.98, isValid: !empty)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: measurements.count)
    }
}
