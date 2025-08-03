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
                
                VStack(alignment: .leading, spacing: .spacingXS) {
                    ContainerViewHeader(
                        title: "Calories",
                        trailingItems: {
                            NavigationLink {
                                CaloriesHistory()
                            } label: {
                                Image(systemName: "list.bullet.clipboard")
                                    .pageTitleImage()
                            }
                            .textColor()
                            .animatedButton()
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: .spacingL) {
                        ChartDateRangeControl(selectedRangeIndex: $selectedRangeIndex)
                        
                        if show {
                            ScrollView {
                                VStack(alignment: .leading, spacing: .spacingL) {
                                    // Calories
                                    VStack(alignment: .leading, spacing: .spacingXS) {
                                        Text("CALORIES")
                                            .subheadingText()
                                            .textColor()
                                        
                                        LineChart(
                                            selectedRangeIndex: $selectedRangeIndex,
                                            data: caloriesData,
                                            units: "cal",
                                            showTime: false
                                        )
                                    }
                                    
                                    // Macros
                                    VStack(alignment: .leading, spacing: .spacingXS) {
                                        Text("MACROS")
                                            .subheadingText()
                                            .textColor()
                                        
                                        MultiLineChart(
                                            selectedRangeIndex: $selectedRangeIndex,
                                            lineDataSets: macrosData,
                                            units: "g"
                                        )
                                    }
                                }
                            }
                            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                            .scrollIndicators(.hidden)
                            .scrollContentBackground(.hidden)
                        } else {
                            EmptyState(
                                image: "fork.knife",
                                text: "No food entries logged",
                                subtext: "Log your first food"
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
