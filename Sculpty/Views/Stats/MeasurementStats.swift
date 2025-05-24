//
//  MeasurementStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/23/25.
//

import SwiftUI
import SwiftData
import Charts

struct MeasurementStats: View {
    @Environment(\.modelContext) private var context
    
    @Query private var measurements: [Measurement]
    
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
            .map { (date: $0.date, value: $0.measurement) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ContainerView(title: "Measurement Stats", spacing: 20, trailingItems: {
            NavigationLink(destination: Measurements()) {
                Image(systemName: "list.bullet.clipboard")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 24))
            }
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
                        .textColor()
                    }
                    .onChange(of: type) {
                        dataValues = measurements.filter { $0.type == type }
                    }
                } else {
                    Text(type.rawValue)
                        .bodyText(size: 24, weight: .bold)
                        .textColor()
                }
                
                StatsLineChart(data: data, units: dataValues.first?.unit ?? "")
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
