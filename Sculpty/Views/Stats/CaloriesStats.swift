//
//  CaloriesStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/23/25.
//

import SwiftUI
import SwiftData

struct CaloriesStats: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var caloriesLogs: [CaloriesLog]
    
    @State private var selectedRangeIndex: Int = 0
    
    private var show: Bool { !caloriesLogs.isEmpty }
    
    private var caloriesData: [(date: Date, value: Double)] {
        caloriesLogs
            .map { (date: Calendar.current.startOfDay(for: $0.date), value: $0.getTotalCalories()) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var carbsData: [(date: Date, value: Double)] {
        caloriesLogs
            .map { (date: Calendar.current.startOfDay(for: $0.date), value: $0.getTotalCarbs()) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var proteinData: [(date: Date, value: Double)] {
        caloriesLogs
            .map { (date: Calendar.current.startOfDay(for: $0.date), value: $0.getTotalProtein()) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var fatData: [(date: Date, value: Double)] {
        caloriesLogs
            .map { (date: Calendar.current.startOfDay(for: $0.date), value: $0.getTotalFat()) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var macrosData: [LineData] {
        return [
            LineData(data: carbsData, color: .blue, name: "Carbs"),
            LineData(data: proteinData, color: .red, name: "Protein"),
            LineData(data: fatData, color: .orange, name: "Fat")
        ]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack(alignment: .leading) {
                    ContainerViewHeader(
                        title: "Calories Stats",
                        trailingItems: {
                            NavigationLink {
                                CaloriesHistory()
                            } label: {
                                Image(systemName: "list.bullet.clipboard")
                                    .padding(.horizontal, 5)
                                    .font(Font.system(size: 20))
                            }
                            .textColor()
                            .animatedButton()
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ChartDateRangeControl(selectedRangeIndex: $selectedRangeIndex)
                        
                        if show {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                    // Calories
                                    Text("CALORIES")
                                        .headingText(size: 24)
                                        .textColor()
                                        .padding(.bottom, -16)
                                    
                                    LineChart(
                                        selectedRangeIndex: $selectedRangeIndex,
                                        data: caloriesData,
                                        units: "cal",
                                        showTime: false
                                    )
                                    
                                    // Macros
                                    Text("MACROS")
                                        .headingText(size: 24)
                                        .textColor()
                                        .padding(.bottom, -16)
                                    
                                    MultiLineChart(
                                        selectedRangeIndex: $selectedRangeIndex,
                                        lineDataSets: macrosData,
                                        units: "g"
                                    )
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
