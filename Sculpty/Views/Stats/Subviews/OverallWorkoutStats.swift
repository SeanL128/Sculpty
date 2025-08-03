//
//  OverallWorkoutStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI
import SwiftData
import Charts

struct OverallWorkoutStats: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @Query private var workoutLogs: [WorkoutLog]
    
    @State private var selectedRangeIndex: Int = 0
    
    // Consistency
    private var workoutStreak: Int {
        let calendar = Calendar.current
        
        let dailyData = Dictionary(grouping: workoutLogs) { log in
            calendar.startOfDay(for: log.start)
        }.mapValues { logs in
            Double(logs.count)
        }
        
        let today = calendar.startOfDay(for: Date())
        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        let weeklyData = Dictionary(grouping: dailyData) { (dateValue) in
            let (date, _) = dateValue
            return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        }.mapValues { dateValuePairs in
            dateValuePairs.reduce(0.0) { sum, pair in
                sum + pair.value
            }
        }
        
        var streak = 0
        var weekToCheck = currentWeekStart
        
        let currentWeekWorkouts = weeklyData[currentWeekStart] ?? 0.0
        if currentWeekWorkouts >= Double(settings.targetWeeklyWorkouts) {
            streak = 1
        }
        
        while true {
            weekToCheck = calendar.date(byAdding: .weekOfYear, value: -1, to: weekToCheck)! // swiftlint:disable:this line_length force_unwrapping
            let weekWorkouts = weeklyData[weekToCheck] ?? 0.0
            
            if weekWorkouts >= Double(settings.targetWeeklyWorkouts) {
                streak += 1
            } else {
                break
            }
        }
        
        if streak > settings.longestWorkoutStreak {
            settings.longestWorkoutStreak = streak
        }
        
        return streak
    }
    
    // Training Frequency
    @State private var selectedDate: Date?
    @State private var selectedValue: Double?
    @State private var isInteracting: Bool = false
    
    // swiftlint:disable force_unwrapping
    private var data: [(date: Date, value: Double)] {
        let calendar = Calendar.current
        
        let dailyData = Dictionary(grouping: workoutLogs) { log in
            calendar.startOfDay(for: log.start)
        }.mapValues { logs in
            Double(logs.count)
        }
        
        let today = calendar.startOfDay(for: Date())
        let groupByWeek = selectedRangeIndex <= 1
        
        let startDate: Date
        let numberOfPeriods: Int
        
        switch selectedRangeIndex {
        case 0:
            numberOfPeriods = 4
            startDate = calendar.date(byAdding: .weekOfYear, value: -numberOfPeriods + 1, to: today)!
        case 1:
            numberOfPeriods = 12
            startDate = calendar.date(byAdding: .weekOfYear, value: -numberOfPeriods + 1, to: today)!
        case 2:
            numberOfPeriods = 6
            startDate = calendar.date(byAdding: .month, value: -numberOfPeriods + 1, to: today)!
        case 3:
            numberOfPeriods = 12
            startDate = calendar.date(byAdding: .month, value: -numberOfPeriods + 1, to: today)!
        case 4:
            numberOfPeriods = 60
            startDate = calendar.date(byAdding: .month, value: -numberOfPeriods + 1, to: today)!
        default:
            numberOfPeriods = 4
            startDate = calendar.date(byAdding: .weekOfYear, value: -numberOfPeriods + 1, to: today)!
        }
        
        if groupByWeek {
            let weeklyData = Dictionary(grouping: dailyData) { (dateValue) in
                let (date, _) = dateValue
                return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            }.mapValues { dateValuePairs in
                dateValuePairs.reduce(0.0) { sum, pair in
                    sum + pair.value
                }
            }
            
            let weekStartDate = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
            
            var result: [(date: Date, value: Double)] = []
            var currentWeekStart = weekStartDate
            
            for _ in 0..<numberOfPeriods {
                let value = weeklyData[currentWeekStart] ?? 0.0
                result.append((date: currentWeekStart, value: value))
                currentWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart)!
            }
            
            return result.sorted { $0.date < $1.date }
            
        } else {
            let monthlyData = Dictionary(grouping: dailyData) { (dateValue) in
                let (date, _) = dateValue
                let components = calendar.dateComponents([.year, .month], from: date)
                return calendar.date(from: components)!
            }.mapValues { dateValuePairs in
                dateValuePairs.reduce(0.0) { sum, pair in
                    sum + pair.value
                }
            }
            
            let monthComponents = calendar.dateComponents([.year, .month], from: startDate)
            let monthStartDate = calendar.date(from: monthComponents)!
            
            var result: [(date: Date, value: Double)] = []
            var currentMonthStart = monthStartDate
            
            for _ in 0..<numberOfPeriods {
                let value = monthlyData[currentMonthStart] ?? 0.0
                result.append((date: currentMonthStart, value: value))
                currentMonthStart = calendar.date(byAdding: .month, value: 1, to: currentMonthStart)!
            }
            
            return result.sorted { $0.date < $1.date }
        }
    }
    // swiftlint:enable force_unwrapping
    
    private var labelIndexes: [Int] {
        switch selectedRangeIndex {
        case 0: return [0, 1, 2, 3]
        case 1: return [1, 3, 5, 7, 9, 11]
        case 2: return [1, 3, 5]
        case 3: return [1, 4, 7, 10]
        case 4: return [11, 23, 35, 47]
        default: return [0, 1, 2, 3]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Consistency
                    VStack(alignment: .leading, spacing: .spacingXS) {
                        Text("CONSISTENCY")
                            .subheadingText()
                            .textColor()
                        
                        // swiftlint:disable line_length
                        VStack(alignment: .leading, spacing: .spacingXS) {
                            Text("Current Streak: \(workoutStreak) week\(workoutStreak != 1 ? "s" : "") in a row with \(settings.targetWeeklyWorkouts)+ workouts")
                                .bodyText(weight: .regular)
                                .textColor()
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .animation(.easeInOut(duration: 0.3), value: workoutStreak)
                            
                            Text("Longest Streak: \(settings.longestWorkoutStreak) week\(settings.longestWorkoutStreak != 1 ? "s" : "")")
                                .secondaryText()
                                .secondaryColor()
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .animation(.easeInOut(duration: 0.3), value: settings.longestWorkoutStreak)
                        }
                        // swiftlint:enable line_length
                    }
                    
                    // Training Frequency
                    VStack(alignment: .leading, spacing: .spacingXS) {
                        Text("TRAINING FREQUENCY")
                            .subheadingText()
                            .textColor()
                        
                        VStack(alignment: .leading, spacing: .spacingM) {
                            ZStack(alignment: .top) {
                                Chart {
                                    ForEach(data, id: \.date) { item in
                                        BarMark(
                                            x: .value(
                                                "Week",
                                                selectedRangeIndex <= 1 ? formatDateNoYear(item.date) : formatMonth(item.date) // swiftlint:disable:this line_length
                                            ),
                                            y: .value("Value", item.value)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    }
                                    
                                    if let selectedDate = selectedDate {
                                        RuleMark(
                                            x: .value(
                                                "Selected Date",
                                                selectedRangeIndex <= 1 ? formatDateNoYear(selectedDate) : formatMonth(selectedDate) // swiftlint:disable:this line_length
                                            )
                                        )
                                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                        .foregroundStyle(ColorManager.text)
                                    }
                                }
                                .frame(height: 250)
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisGridLine()
                                        AxisValueLabel {
                                            if let date = value.as(String.self),
                                               let index = data
                                                .map({
                                                    selectedRangeIndex <= 1 ? formatDateNoYear($0.date) : formatMonth($0.date) // swiftlint:disable:this line_length
                                                })
                                                .firstIndex(of: date),
                                               labelIndexes.contains(index) {
                                                Text(date)
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
                                                Text("\(numericValue.formatted())x")
                                                    .captionText()
                                                    .textColor()
                                            }
                                        }
                                    }
                                }
                                .chartGesture { proxy in
                                    DragGesture(minimumDistance: 8)
                                        .onChanged { value in
                                            if !isInteracting {
                                                isInteracting = true
                                            }
                                            
                                            if let dateString: String = proxy.value(atX: value.location.x) {
                                                let newSelectedDate = findClosestDataPointFromString(dateString)
                                                
                                                if newSelectedDate != selectedDate {
                                                    selectedDate = newSelectedDate
                                                    
                                                    selectedValue = findClosestDataPointValue(to: newSelectedDate)
                                                }
                                            }
                                        }
                                        .onEnded { _ in
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                isInteracting = false
                                                selectedDate = nil
                                                selectedValue = nil
                                            }
                                        }
                                }
                                .animation(.easeInOut(duration: 0.5), value: selectedRangeIndex)
                                .animation(.easeInOut(duration: 0.3), value: data.count)
                                
                                if isInteracting,
                                   let date = selectedDate,
                                   let value = selectedValue,
                                   !data.isEmpty {
                                    
                                    VStack(alignment: .leading, spacing: .spacingXS) {
                                        Text(selectedRangeIndex <= 1 ? "Week of \(formatDateNoYear(date))" : formatMonth(date)) // swiftlint:disable:this line_length
                                            .captionText()
                                        
                                        Text("\(value.formatted())x")
                                            .captionText()
                                    }
                                    .padding(.spacingS)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(ColorManager.surface)
                                            .stroke(ColorManager.border)
                                    )
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.2), value: isInteracting)
                                    .offset(x: 0, y: 5)
                                }
                            }
                            .padding()
                            .animation(.easeInOut(duration: 0.4), value: data.count)
                            .animation(.easeInOut(duration: 0.3), value: selectedRangeIndex)
                            .drawingGroup()
                            
                            TypedSegmentedControl(
                                selection: $selectedRangeIndex,
                                options: [0, 1, 2, 3, 4],
                                displayNames: [
                                    "Last 4 Weeks",
                                    "Last 12 Weeks",
                                    "Last 6 Months",
                                    "Last Year",
                                    "Last 5 Years"
                                ]
                            )
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
    }
    
    private func findClosestDataPointFromString(_ dateString: String) -> Date? {
        return data.first { item in
            let formattedDate = selectedRangeIndex <= 1 ? formatDateNoYear(item.date) : formatMonth(item.date)
            return formattedDate == dateString
        }?.date
    }
    
    private func findClosestDataPoint(to date: Date) -> Date? {
        guard !data.isEmpty else { return nil }
        
        let targetTime = date.timeIntervalSince1970
        var left = 0
        var right = data.count - 1
        var closest = data[0].date
        var minDiff = abs(data[0].date.timeIntervalSince1970 - targetTime)
        
        while left <= right {
            let mid = (left + right) / 2
            let midTime = data[mid].date.timeIntervalSince1970
            let diff = abs(midTime - targetTime)
            
            if diff < minDiff {
                minDiff = diff
                closest = data[mid].date
            }
            
            if midTime < targetTime {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        return closest
    }
    
    private func findClosestDataPointValue(to date: Date?) -> Double? {
        guard let date = date else { return nil }
        return data.first { $0.date == date }?.value
    }
}
