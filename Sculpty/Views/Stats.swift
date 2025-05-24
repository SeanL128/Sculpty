//
//  Stats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/19/25.
//

import SwiftUI
import SwiftData
import Charts
import BRHSegmentedControl

struct Stats: View {
    @State private var selectedTab: Int = 0
    
    @Namespace private var animation
    
    var body: some View {
        ContainerView(title: "Stats", spacing: 20) {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        VStack(spacing: 4) {
                            Text(index == 0 ? "WORKOUTS" : index == 1 ? "FOOD ENTRIES" : "MEASUREMENTS")
                                .headingText(size: 16)
                                .foregroundStyle(selectedTab == index ? ColorManager.text : ColorManager.secondary)
                                .frame(maxWidth: .infinity)
                            
                            if selectedTab == index {
                                Rectangle()
                                    .fill(Color.accent)
                                    .frame(height: 3)
                                    .matchedGeometryEffect(id: "underline", in: animation)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                        .frame(width: geometry.size.width / 3)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedTab = index
                            }
                        }
                    }
                }
            }
            .frame(height: 20)
            
            ZStack(alignment: .topLeading) {
                let width = UIScreen.main.bounds.width
                
                // Workouts View
                WorkoutsView()
                    .offset(x: CGFloat(0 - selectedTab) * width)
                
                // Food Entries View
                FoodEntriesView()
                    .offset(x: CGFloat(1 - selectedTab) * width)
                
                // Measurements View
                MeasurementsView()
                    .offset(x: CGFloat(2 - selectedTab) * width)
            }
            .animation(.easeInOut, value: selectedTab)
        }
    }
}

// Placeholder views for each tab
struct WorkoutsView: View {
    @State private var show: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if show {
                
            }
        }
    }
}

struct FoodEntriesView: View {
    var body: some View {
        VStack {
            Text("Food Entry Statistics")
                .font(.title2)
                .padding()
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accent.opacity(0.1))
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 40))
                        .foregroundColor(.accent)
                )
                .frame(height: 200)
                .padding()
        }
    }
}

struct MeasurementsView: View {
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
        VStack(alignment: .leading, spacing: 20) {
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
