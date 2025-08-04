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
        
        return measurements.filter { $0.type == type }
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
                
                VStack(alignment: .leading, spacing: .spacingXS) {
                    ContainerViewHeader(
                        title: "Measurements",
                        trailingItems: {
                            NavigationLink {
                                Measurements()
                            } label: {
                                Image(systemName: "list.bullet.clipboard")
                                    .pageTitleImage()
                            }
                            .textColor()
                            .animatedButton(feedback: .selection)
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: .spacingL) {
                        NavigationLink {
                            SelectMeasurement(selectedMeasurementType: $type)
                        } label: {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text(type?.rawValue ?? "Select Measurement")
                                    .bodyText(weight: .regular)
                                
                                Image(systemName: "chevron.right")
                                    .bodyImage()
                            }
                        }
                        .textColor()
                        .animatedButton(feedback: .selection)
                        
                        ChartDateRangeControl(selectedRangeIndex: $selectedRangeIndex)
                        
                        if show {
                            ScrollView {
                                VStack(alignment: .leading, spacing: .spacingXS) {
                                    // Measurement
                                    Text("MEASUREMENT")
                                        .subheadingText()
                                        .textColor()
                                    
                                    LineChart(selectedRangeIndex: $selectedRangeIndex, data: data, units: units)
                                }
                            }
                            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                            .scrollIndicators(.hidden)
                            .scrollContentBackground(.hidden)
                        } else {
                            EmptyState(
                                image: "ruler",
                                text: "No measurements logged",
                                subtext: "Log your first measurement"
                            )
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: show)
                    
                    Spacer()
                }
                .padding(.top, .spacingM)
                .padding(.bottom, .spacingXS)
                .padding(.horizontal, .spacingL)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
