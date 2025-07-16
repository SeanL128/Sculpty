//
//  MeasurementStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/23/25.
//

import SwiftUI
import SwiftData

struct MeasurementStats: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var measurements: [Measurement]
    
    @State private var selectedRangeIndex: Int = 0
    
    private var show: Bool { !data.isEmpty }
    
    @State private var type: MeasurementType?
    
    private var filteredMeasurements: [Measurement] {
        guard let type = type else { return [] }
        
        let descriptor = FetchDescriptor<Measurement>(
            predicate: #Predicate<Measurement> { $0.type == type },
            sortBy: [SortDescriptor(\Measurement.date)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }

    private var data: [(date: Date, value: Double)] {
        filteredMeasurements.map { (date: $0.date, value: $0.getConvertedMeasurement()) }
    }
    
    private var units: String {
        switch type {
        case .bodyFat: return "%"
        case .weight: return UnitsManager.weight
        default: return UnitsManager.shortLength
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack(alignment: .leading) {
                    ContainerViewHeader(
                        title: "Measurement Stats",
                        trailingItems: {
                            NavigationLink {
                                Measurements()
                            } label: {
                                Image(systemName: "list.bullet.clipboard")
                                    .padding(.trailing, 5)
                                    .font(Font.system(size: 20))
                            }
                            .textColor()
                            .animatedButton()
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: 20) {
                        NavigationLink {
                            SelectMeasurement(selectedMeasurementType: $type, forStats: true)
                        } label: {
                            HStack(alignment: .center) {
                                Text(type?.rawValue ?? "Select Measurement")
                                    .bodyText(size: 20, weight: .bold)
                                
                                Image(systemName: "chevron.right")
                                    .padding(.leading, -2)
                                    .font(Font.system(size: 14, weight: .bold))
                            }
                        }
                        .textColor()
                        .animatedButton(scale: 0.98)
                        
                        ChartDateRangeControl(selectedRangeIndex: $selectedRangeIndex)
                        
                        if show {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                    // Measurement
                                    Text("MEASUREMENT")
                                        .headingText(size: 24)
                                        .textColor()
                                        .padding(.bottom, -16)
                                    
                                    LineChart(selectedRangeIndex: $selectedRangeIndex, data: data, units: units)
                                }
                            }
                            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                            .scrollIndicators(.visible)
                            .scrollContentBackground(.hidden)
                        } else {
                            EmptyState(
                                message: "No Data",
                                size: 18
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
