//
//  Measurements.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/11/25.
//

import SwiftUI
import SwiftData
import SwiftUICharts

struct Measurements: View {
    @Query private var measurements: [Measurement]
    
    var body: some View {
        ContainerView(title: "Measurements", spacing: 20) {
            ForEach(MeasurementType.displayOrder, id: \.id) { type in
                let empty = measurements.filter { $0.type == type }.isEmpty
                NavigationLink(destination: MeasurementPage(type: type)) {
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
                .foregroundStyle(empty ? ColorManager.secondary : ColorManager.text)
                .disabled(empty)
            }
        }
    }
}

#Preview {
    Measurements()
}
