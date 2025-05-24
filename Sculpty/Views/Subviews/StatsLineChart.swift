//
//  StatsLineChart.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/22/25.
//

import SwiftUI
import Charts
import BRHSegmentedControl

struct StatsLineChart: View {
    @State private var selectedRangeIndex: Int = 0
    private var endDate: Date {
        Date()
    }
    private var startDate: Date {
        switch selectedRangeIndex {
        case 0: return Calendar.current.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        case 1: return Calendar.current.date(byAdding: .day, value: -29, to: endDate) ?? endDate
        case 2: return Calendar.current.date(byAdding: .month, value: -6, to: endDate) ?? endDate
        case 3: return Calendar.current.date(byAdding: .year, value: -1, to: endDate) ?? endDate
        default: return data.sorted { $0.date > $1.date }.last?.date ?? (Calendar.current.date(byAdding: .day, value: -6, to: endDate) ?? endDate)
        }
    }
    
    @State private var selectedDate: Date?
    @State private var selectedValue: Double?
    @State private var isInteracting: Bool = false
    
    var data: [(date: Date, value: Double)]
    var units: String
    
    var body: some View {
        ZStack(alignment: .top) {
            Chart {
                ForEach(data, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(ColorManager.text)
                    
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(ColorManager.text)
                    .symbolSize(36)
                    
                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorManager.text.opacity(0.2), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                if let selectedDate = selectedDate {
                    RuleMark(
                        x: .value("Selected Date", selectedDate)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .foregroundStyle(ColorManager.secondary)
                }
            }
            .chartXScale(domain: startDate...endDate)
            .frame(height: 250)
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(formatDateNoYear(date))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let numericValue = value.as(Double.self) {
                            Text("\(numericValue.formatted())\(units)")
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let xPosition = value.location.x
                                    
                                    if let date = findClosestDate(at: xPosition, proxy: proxy, geometry: geometry) {
                                        self.selectedDate = date
                                        self.selectedValue = data.first { $0.date == date }?.value
                                        self.isInteracting = true
                                    }
                                }
                                .onEnded { _ in
                                     self.selectedDate = nil
                                     self.selectedValue = nil
                                     self.isInteracting = false
                                }
                        )
                }
            }
            
            if isInteracting, let date = selectedDate, let value = selectedValue {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDateWithTime(date))
                        .bodyText(size: 12)
                    Text("Value: \(value.formatted())")
                        .bodyText(size: 12, weight: .bold)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorManager.background)
                        .shadow(radius: 2)
                )
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: isInteracting)
                .offset(x: 0)
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.5), value: selectedRangeIndex)
        
        BRHSegmentedControl(
            selectedIndex: $selectedRangeIndex,
            labels: ["Last 7 Days", "Last 30 Days", "Last 6 Months", "Last Year", "All Time"],
            builder: { _, label in
                Text(label)
                    .bodyText(size: 12)
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
    }
    
    private func findClosestDate(at position: CGFloat, proxy: ChartProxy, geometry: GeometryProxy) -> Date? {
        if let date = proxy.value(atX: position) as Date? {
            return data
                .map { $0.date }
                .min(by: { abs($0.timeIntervalSince(date)) < abs($1.timeIntervalSince(date)) })
        }
        
        return nil
    }
}
