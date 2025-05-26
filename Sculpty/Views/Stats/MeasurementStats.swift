//
//  MeasurementStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/23/25.
//

import SwiftUI
import SwiftData
import Charts
import BRHSegmentedControl

struct MeasurementStats: View {
    @Environment(\.modelContext) private var context
    
    @Query private var measurements: [Measurement]
    
    @State private var selectedRangeIndex: Int = 0
    
    @State private var show: Bool = true
    
    @State private var type: MeasurementType = .weight
    private var typeOptions: [String : MeasurementType] {
        var dict: [String: MeasurementType] = [:]
        
        for type in MeasurementType.displayOrder {
            if !measurements.filter({ $0.type == type }).isEmpty {
                dict[type.rawValue] = type
            }
        }
        
        return dict
    }
    
    @State private var dataValues: [Measurement] = []
    private var data: [(date: Date, value: Double)] {
        dataValues
            .map { (date: $0.date, value: $0.getConvertedMeasurement()) }
            .sorted { $0.date < $1.date }
    }
    private var units: String {
        switch type {
        case .bodyFat: return "%"
        case .weight: return UnitsManager.weight
        default: return UnitsManager.shortLength
        }
    }
    
    var body: some View {
        ContainerView(title: "Measurement Stats", spacing: 20, trailingItems: {
            NavigationLink(destination: Measurements()) {
                Image(systemName: "list.bullet.clipboard")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 24))
            }
            .textColor()
        }) {
            if show {
                if typeOptions.keys.count > 1 {
                    Button {
                        Task {
                            await MeasurementMenuPopup(options: typeOptions, selection: $type).present()
                        }
                    } label: {
                        HStack(alignment: .center) {
                            Text(type.rawValue)
                                .bodyText(size: 24, weight: .bold)
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 10, weight: .bold))
                        }
                    }
                    .textColor()
                    .onChange(of: type) {
                        dataValues = measurements.filter { $0.type == type }
                    }
                    .padding(.bottom, -8)
                } else {
                    Text(type.rawValue)
                        .bodyText(size: 24, weight: .bold)
                        .textColor()
                        .padding(.bottom, -8)
                }
                
                BRHSegmentedControl(
                    selectedIndex: $selectedRangeIndex,
                    labels: ["Last 7 Days", "Last 30 Days", "Last 6 Months", "Last Year", "Last 5 Years"],
                    builder: { _, label in
                        Text(label)
                            .bodyText(size: 12)
                            .multilineTextAlignment(.center)
                    },
                    styler: { state in
                        switch state {
                        case .none:
                            return ColorManager.secondary
                        case .touched:
                            return ColorManager.secondary.opacity(0.7)
                        case .selected:
                            return ColorManager.text
                        }
                    }
                )
                .padding(.bottom, -8)
                
                // Measurement
                Text("MEASUREMENT")
                    .headingText(size: 24)
                    .textColor()
                    .padding(.bottom, -16)
                
                StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: data, units: units)
            } else {
                Text("No Data")
                    .bodyText(size: 20)
                    .textColor()
            }
        }
        .onAppear() {
            dataValues = measurements.filter { $0.type == type }
            
            if typeOptions.isEmpty {
                show = false
            } else if !typeOptions.keys.contains(where: { $0 == type.rawValue }) {
                type = MeasurementType(rawValue: typeOptions.keys.first!)!
            }
        }
    }
}
