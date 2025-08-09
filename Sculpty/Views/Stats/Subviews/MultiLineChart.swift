//
//  MultiLineChart.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/28/25.
//

import SwiftUI
import Charts

struct MultiLineChart: View {
    @Binding var selectedRangeIndex: Int
    private var endDate: Date {
        Date()
    }
    private var startDate: Date {
        switch selectedRangeIndex {
        case 0: return Calendar.current.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        case 1: return Calendar.current.date(byAdding: .day, value: -29, to: endDate) ?? endDate
        case 2: return Calendar.current.date(byAdding: .month, value: -6, to: endDate) ?? endDate
        case 3: return Calendar.current.date(byAdding: .year, value: -1, to: endDate) ?? endDate
        default: return Calendar.current.date(byAdding: .year, value: -5, to: endDate) ?? endDate
        }
    }
    
    @State private var animationStates: [Date: Bool] = [:]
    
    @State private var selectedDate: Date?
    @State private var isInteracting: Bool = false
    
    var lineDataSets: [LineChartData]
    var units: String
    
    private var allChartData: [LineChartData] {
        lineDataSets.map { lineData in
            let filteredData = lineData.data.filter { $0.date >= startDate && $0.date <= endDate }
                .sorted { $0.date < $1.date }
            return LineChartData(data: filteredData, color: lineData.color, name: lineData.name)
        }
    }
    
    private var allDataPoints: [(date: Date, value: Double)] {
        allChartData.flatMap { $0.data }.sorted { $0.date < $1.date }
    }
    
    private var allUniqueDates: [Date] {
        allChartData.flatMap { $0.data.map { $0.date } }.removingDuplicates().sorted()
    }
    
    private var selectedValues: [(name: String, value: Double, color: Color)] {
        guard let selectedDate = selectedDate else { return [] }
        
        return allChartData.compactMap { lineData in
            if let value = findClosestDataPointValue(to: selectedDate, in: lineData.data) {
                return (name: lineData.name, value: value, color: lineData.color)
            }
            return nil
        }
    }
    
    private var maxValue: Double {
        allChartData.flatMap { $0.data.map { $0.value } }.max() ?? 0
    }
    
    @State private var interactingTrigger: Int = 0
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Chart {
                        ForEach(allChartData, id: \.id) { lineData in
                            ForEach(lineData.data, id: \.date) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value),
                                    series: .value("", lineData.name)
                                )
                                .foregroundStyle(lineData.color)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                
                                AreaMark(
                                    x: .value("Date", item.date),
                                    y: .value("Value", item.value),
                                    series: .value("", lineData.name),
                                    stacking: .unstacked
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [lineData.color.opacity(0.2), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                
                                if selectedRangeIndex <= 1,
                                   animationStates[item.date] == true {
                                    PointMark(
                                        x: .value("Date", item.date),
                                        y: .value("Value", item.value)
                                    )
                                    .foregroundStyle(lineData.color)
                                    .symbolSize(24)
                                }
                            }
                        }
                        
                        if let selectedDate = selectedDate {
                            RuleMark(
                                x: .value("Selected Date", selectedDate)
                            )
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .foregroundStyle(ColorManager.text)
                        }
                    }
                    .chartXScale(domain: startDate...endDate)
                    .chartXAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(selectedRangeIndex <= 1 ? formatDateNoYear(date) : formatMonth(date))
                                        .captionText()
                                        .textColor()
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
                                        .captionText()
                                        .textColor()
                                }
                            }
                        }
                    }
                    .chartYScale(domain: 0...max(maxValue, 1))
                    .chartXSelection(value: .constant(selectedDate))
                    .chartGesture { proxy in
                        DragGesture(minimumDistance: 8)
                            .onChanged { value in
                                if !isInteracting {
                                    isInteracting = true
                                }
                                
                                if let date: Date = proxy.value(atX: value.location.x) {
                                    let newSelectedDate = findClosestDataPoint(to: date)
                                    
                                    if newSelectedDate != selectedDate {
                                        selectedDate = newSelectedDate
                                        
                                        interactingTrigger += 1
                                    }
                                }
                            }
                            .onEnded { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isInteracting = false
                                    selectedDate = nil
                                }
                            }
                    }
                    .onAppear {
                        initializeAnimations()
                    }
                    .onChange(of: selectedRangeIndex) {
                        animationStates = [:]
                        
                        for (index, date) in allUniqueDates.enumerated() {
                            withAnimation(.linear.delay(Double(index) * 0.05)) {
                                animationStates[date] = false
                            }
                        }
                        
                        initializeAnimations()
                    }
                    .hapticFeedback(.selection, trigger: interactingTrigger)
                    
                    if isInteracting,
                       let date = selectedDate,
                       !selectedValues.isEmpty,
                       !allDataPoints.isEmpty {
                        
                        VStack(alignment: .leading, spacing: .spacingXS) {
                            Text(formatDate(date))
                                .captionText()
                                .textColor()
                            
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(selectedValues.enumerated()), id: \.offset) { _, item in
                                    HStack(spacing: .spacingXS) {
                                        Circle()
                                            .fill(item.color)
                                            .frame(width: 8, height: 8)
                                        
                                        Text("\(item.name): \(item.value.formatted())\(units)")
                                            .captionText()
                                            .foregroundStyle(item.color)
                                    }
                                }
                            }
                        }
                        .padding(.spacingS)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorManager.surface)
                                .stroke(ColorManager.border)
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isInteracting)
                        .position(tooltipPosition(in: geo))
                    }
                }
            }
            .frame(height: 250)
            .padding()
        }
        .animation(.easeInOut(duration: 0.5), value: selectedRangeIndex)
        .drawingGroup()
    }
    
    private func initializeAnimations() {
        for (index, date) in allUniqueDates.enumerated() {
            withAnimation(.linear(duration: 0.1).delay(Double(index) * 0.1)) {
                animationStates[date] = true
            }
        }
    }
    
    private func findClosestDataPoint(to date: Date) -> Date? {
        guard !allDataPoints.isEmpty else { return nil }
        
        let targetTime = date.timeIntervalSince1970
        var left = 0
        var right = allDataPoints.count - 1
        var closest = allDataPoints[0].date
        var minDiff = abs(allDataPoints[0].date.timeIntervalSince1970 - targetTime)
        
        while left <= right {
            let mid = (left + right) / 2
            let midTime = allDataPoints[mid].date.timeIntervalSince1970
            let diff = abs(midTime - targetTime)
            
            if diff < minDiff {
                minDiff = diff
                closest = allDataPoints[mid].date
            }
            
            if midTime < targetTime {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        return closest
    }
    
    private func findClosestDataPointValue(to date: Date, in data: [(date: Date, value: Double)]) -> Double? {
        return data.first { $0.date == date }?.value
    }
    
    private func tooltipPosition(in geo: GeometryProxy) -> CGPoint {
        guard let selectedDate = selectedDate else {
            return CGPoint(x: geo.size.width / 2, y: 50)
        }
        
        let totalTimeInterval = endDate.timeIntervalSince(startDate)
        let selectedTimeInterval = selectedDate.timeIntervalSince(startDate)
        let relativePosition = max(0, min(1, selectedTimeInterval / totalTimeInterval))
        
        let chartPadding: CGFloat = 40
        let availableWidth = geo.size.width - (chartPadding * 2)
        let xPosition = chartPadding + (availableWidth * relativePosition)
        
        let tooltipWidth: CGFloat = 150
        let clampedX = max(tooltipWidth / 2 + 10,
                           min(geo.size.width - tooltipWidth / 2 - 10, xPosition))
        
        return CGPoint(x: clampedX, y: 30)
    }
}
