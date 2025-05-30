//
//  CaloriesStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/23/25.
//

import SwiftUI
import SwiftData
import Charts
import BRHSegmentedControl

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
                    HStack(alignment: .center) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(.trailing, 6)
                                .font(Font.system(size: 22))
                        }
                        .textColor()
                        
                        Text("CALORIES STATS")
                            .headingText(size: 32)
                            .textColor()
                        
                        Spacer()
                        
                        NavigationLink(destination: CaloriesHistory()) {
                            Image(systemName: "list.bullet.clipboard")
                                .padding(.horizontal, 5)
                                .font(Font.system(size: 20))
                        }
                        .textColor()
                    }
                    .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 20) {
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
                        
                        if show {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                    // Calories
                                    Text("CALORIES")
                                        .headingText(size: 24)
                                        .textColor()
                                        .padding(.bottom, -16)
                                    
                                    LineChart(selectedRangeIndex: $selectedRangeIndex, data: caloriesData, units: "cal", showTime: false)
                                    
                                    // Macros
                                    Text("MACROS")
                                        .headingText(size: 24)
                                        .textColor()
                                        .padding(.bottom, -16)
                                    
                                    MultiLineChart(selectedRangeIndex: $selectedRangeIndex, lineDataSets: macrosData, units: "g")
                                }
                            }
                            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                            .scrollIndicators(.visible)
                            .scrollContentBackground(.hidden)
                        } else {
                            Text("No Data")
                                .bodyText(size: 18)
                                .textColor()
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
