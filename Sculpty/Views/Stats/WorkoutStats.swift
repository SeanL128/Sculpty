//
//  WorkoutStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/23/25.
//

import SwiftUI
import SwiftData
import Charts
import BRHSegmentedControl

struct WorkoutStats: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var workoutLogs: [WorkoutLog]
    
    private var show: Bool { !workoutLogs.isEmpty }
    
    @State private var selectedTab: Int = 0
    @Namespace private var animation
    
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
                        
                        Text("WORKOUT STATS")
                            .headingText(size: 32)
                            .textColor()
                        
                        Spacer()
                        
                        NavigationLink(destination: WorkoutLogs()) {
                            Image(systemName: "list.bullet.clipboard")
                                .padding(.horizontal, 5)
                                .font(Font.system(size: 24))
                        }
                        .textColor()
                    }
                    .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        if show {
                            GeometryReader { geometry in
                                HStack(spacing: 0) {
                                    VStack(spacing: 4) {
                                        Text("OVERALL")
                                            .headingText(size: 16)
                                            .foregroundStyle(selectedTab == 0 ? ColorManager.text : ColorManager.secondary)
                                            .frame(maxWidth: .infinity)
                                        
                                        if selectedTab == 0 {
                                            Rectangle()
                                                .fill(ColorManager.text)
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
                                            selectedTab = 0
                                        }
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text("BY WORKOUT")
                                            .headingText(size: 16)
                                            .foregroundStyle(selectedTab == 1 ? ColorManager.text : ColorManager.secondary)
                                            .frame(maxWidth: .infinity)
                                        
                                        if selectedTab == 1 {
                                            Rectangle()
                                                .fill(ColorManager.text)
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
                                            selectedTab = 1
                                        }
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text("BY EXERCISE")
                                            .headingText(size: 16)
                                            .foregroundStyle(selectedTab == 2 ? ColorManager.text : ColorManager.secondary)
                                            .frame(maxWidth: .infinity)
                                        
                                        if selectedTab == 2 {
                                            Rectangle()
                                                .fill(ColorManager.text)
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
                                            selectedTab = 2
                                        }
                                    }
                                }
                            }
                            .frame(height: 20)
                            
                            ZStack(alignment: .topLeading) {
                                let width = UIScreen.main.bounds.width
                                
                                // Overall View
                                OverallStats()
                                    .offset(x: CGFloat(0 - selectedTab) * width)
                                
                                // Workout View
                                ByWorkoutStats()
                                    .offset(x: CGFloat(1 - selectedTab) * width)
                                
                                // Exercise View
                                ByExerciseStats()
                                    .offset(x: CGFloat(2 - selectedTab) * width)
                            }
                            .animation(.easeInOut, value: selectedTab)
                        } else {
                            Text("No Data")
                                .bodyText(size: 20)
                                .textColor()
                        }
                    }
                }
                .padding()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: Overall
private struct OverallStats: View {
    @Environment(\.modelContext) private var context
    
    @Query private var workoutLogs: [WorkoutLog]
    
    @State private var selectedRangeIndex: Int = 0
    
    // Consistency
    @AppStorage(UserKeys.targetWeeklyWorkouts.rawValue) private var targetWeeklyWorkouts: Int = 3
    @AppStorage(UserKeys.longestWorkoutStreak.rawValue) private var longestWorkoutStreak: Int = 0
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
        if currentWeekWorkouts >= Double(targetWeeklyWorkouts) {
            streak = 1
        }
        
        while true {
            weekToCheck = calendar.date(byAdding: .weekOfYear, value: -1, to: weekToCheck)!
            let weekWorkouts = weeklyData[weekToCheck] ?? 0.0
            
            if weekWorkouts >= Double(targetWeeklyWorkouts) {
                streak += 1
            } else {
                break
            }
        }
        
        if streak > longestWorkoutStreak {
            longestWorkoutStreak = streak
        }
        
        return streak
    }
    
    // Training Frequency
    @State private var selectedDate: Date?
    @State private var selectedValue: Double?
    @State private var isInteracting: Bool = false
    
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
            
            return result
            
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
            
            return result
        }
    }
    private var labelIndexes: [Int] {
        switch selectedRangeIndex {
        case 0: return [0, 1, 2, 3]
        case 1: return [1, 3, 5, 7, 9]
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
                    Text("CONSISTENCY")
                        .headingText(size: 24)
                        .textColor()
                        .padding(.bottom, -16)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Streak: \(workoutStreak) week\(workoutStreak != 1 ? "s" : "") in a row with \(targetWeeklyWorkouts)+ workouts")
                            .bodyText(size: 16)
                        
                        Spacer()
                            .frame(height: 2)
                        
                        Text("Longest Streak: \(longestWorkoutStreak) week\(longestWorkoutStreak != 1 ? "s" : "")")
                            .bodyText(size: 14)
                        
                        Text("Keep going!")
                            .bodyText(size: 14)
                    }
                    .textColor()
                    
                    // Training Frequency
                    Text("TRAINING FREQUENCY")
                        .headingText(size: 24)
                        .textColor()
                        .padding(.bottom, -16)
                    
                    ZStack(alignment: .top) {
                        Chart {
                            ForEach(data, id: \.date) { item in
                                BarMark(
                                    x: .value("Week", selectedRangeIndex <= 1 ? formatDateNoYear(item.date) : formatMonth(item.date)),
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
                                    x: .value("Selected Date", selectedRangeIndex <= 1 ? formatDateNoYear(selectedDate) : formatMonth(selectedDate))
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
                                       let index = data.map({ selectedRangeIndex <= 1 ? formatDateNoYear($0.date) : formatMonth($0.date) }).firstIndex(of: date),
                                       labelIndexes.contains(index) {
                                        Text(date)
                                            .bodyText(size: 12)
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
                                            .bodyText(size: 12)
                                            .textColor()
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
                                Text(selectedRangeIndex <= 1 ? "Week of \(formatDateNoYear(date))" : formatMonth(date))
                                    .bodyText(size: 12)
                                Text("\(value.formatted())x")
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
                        labels: ["Last 4 Weeks", "Last 12 Weeks", "Last 6 Months", "Last Year", "Last 5 Years"],
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
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
    }
    
    private func findClosestDate(at position: CGFloat, proxy: ChartProxy, geometry: GeometryProxy) -> Date? {
        if let date = proxy.value(atX: position) as String? {
            return data
                .map { $0.date }
                .first(where: { [formatDateNoYear($0), formatMonth($0)].contains(date)})
        }
        
        return nil
    }
}

// MARK: By Workout
private struct ByWorkoutStats: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Workout.index) private var workouts: [Workout]
    @Query private var workoutLogs: [WorkoutLog]
    
    @State private var selectedRangeIndex: Int = 0
    
    @AppStorage(UserKeys.includeWarmUp.rawValue) private var includeWarmUp: Bool = true
    @AppStorage(UserKeys.includeDropSet.rawValue) private var includeDropSet: Bool = true
    @AppStorage(UserKeys.includeCoolDown.rawValue) private var includeCoolDown: Bool = true
    
    @State private var workout: Workout?
    private var workoutOptions: [Workout] {
        workouts.filter { workout in
            !workoutLogs.filter { $0.workout == workout}.isEmpty
        }
    }
    
    private var dataValues: [WorkoutLog] {
        workoutLogs.filter { $0.workout == workout }
    }
    private var weightData: [(date: Date, value: Double)] {
        dataValues
            .map { (date: $0.start, value: $0.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown)) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var repsData: [(date: Date, value: Double)] {
        dataValues
            .map { (date: $0.start, value: Double($0.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown))) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var distanceData: [(date: Date, value: Double)] {
        dataValues
            .map { (date: $0.start, value: $0.getTotalDistance(includeWarmUp, includeDropSet, includeCoolDown)) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var timeData: [(date: Date, value: Double)] {
        dataValues
            .map { (date: $0.start, value: round(($0.getTotalTime(includeWarmUp, includeDropSet, includeCoolDown) / 60) * 100) / 100.0) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var durationData: [(date: Date, value: Double)] {
        dataValues
            .map { (date: $0.start, value: round(($0.getLength() / 60) * 100) / 100.0) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    
    private var showWeightData: Bool { !weightData.isEmpty || !repsData.isEmpty }
    private var showDistanceData: Bool { !distanceData.isEmpty || !timeData.isEmpty }
    private var showDurationData: Bool { !durationData.isEmpty }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if workoutOptions.count > 1 {
                Button {
                    Task {
                        await WorkoutMenuPopup(options: workoutOptions, selection: $workout).present()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Text(workout?.name ?? "Select Workout")
                            .bodyText(size: 24, weight: .bold)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 10, weight: .bold))
                    }
                }
                .textColor()
                .padding(.bottom, -8)
            } else {
                Text(workout?.name ?? "Workout")
                    .bodyText(size: 24, weight: .bold)
                    .textColor()
                    .padding(.bottom, -8)
            }
            
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
            
            if showWeightData || showDistanceData || showDurationData {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if showWeightData {
                            // Weight
                            Text("TOTAL WEIGHT")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: weightData, units: UnitsManager.weight)
                            
                            // Reps
                            Text("TOTAL REPS")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: repsData, units: "reps")
                        }
                        
                        if showDistanceData {
                            // Distance
                            Text("TOTAL DISTANCE")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: distanceData, units: UnitsManager.longLength)
                            
                            // Time (Cardio)
                            Text("TOTAL CARDIO TIME")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: timeData, units: "min")
                        }
                        
                        if showDurationData {
                            Text("TOTAL WORKOUT DURATION")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: durationData, units: "min")
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity)
            } else {
                Text("No Data")
                    .bodyText(size: 20)
                    .textColor()
            }
        }
        .onAppear() {
            if !workoutOptions.isEmpty {
                workout = workoutOptions.first!
            }
        }
    }
}

// MARK: By Exercise
private struct ByExerciseStats: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Workout.index) private var workouts: [Workout]
    @Query private var workoutLogs: [WorkoutLog]
    @Query private var exerciseLogs: [ExerciseLog]
    
    @State private var selectedRangeIndex: Int = 0
    
    @AppStorage(UserKeys.includeWarmUp.rawValue) private var includeWarmUp: Bool = true
    @AppStorage(UserKeys.includeDropSet.rawValue) private var includeDropSet: Bool = true
    @AppStorage(UserKeys.includeCoolDown.rawValue) private var includeCoolDown: Bool = true
    
    @State private var exercise: Exercise?
    
    private var dataValues: [WorkoutLog] {
        workoutLogs.filter { $0.exerciseLogs.contains(where: { $0.exercise.exercise?.id == exercise?.id }) }
    }
    private var prData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        var pr: Double = 0
        var prData: [(date: Date, value: Double)] = []
        
        for log in exerciseLogs.filter({ $0.exercise.exercise?.id == exerciseId }) {
            let max = log.setLogs.compactMap { if let weight = $0.weight, let reps = $0.reps { return weight / Double(reps) } else { return nil } }.max() ?? 0
            
            if max > pr {
                pr = max
                prData.append((date: log.start, value: pr))
            }
        }
        
        return prData
    }
    private var oneRmData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map { (date: $0.start, value: $0.exerciseLogs.filter { $0.exercise.exercise?.id == exerciseId }.map { $0.getMaxOneRM() }.max() ?? 0) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var weightData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map { (date: $0.start, value: $0.exerciseLogs.filter { $0.exercise.exercise?.id == exerciseId }.reduce(0) { $0 + $1.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown) })}
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var repsData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map { (date: $0.start, value: Double($0.exerciseLogs.filter { $0.exercise.exercise?.id == exerciseId }.reduce(0) { $0 + $1.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown) }))}
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var distanceData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map { (date: $0.start, value: $0.exerciseLogs.filter { $0.exercise.exercise?.id == exerciseId }.reduce(0) { $0 + $1.getTotalDistance(includeWarmUp, includeDropSet, includeCoolDown) })}
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var timeData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map { (date: $0.start, value: Double(round(($0.exerciseLogs.filter { $0.exercise.exercise?.id == exerciseId }.reduce(0) { $0 + $1.getTotalTime(includeWarmUp, includeDropSet, includeCoolDown) }) / 60) * 100) / 100.0) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
        
//        dataValues
//            .map { (date: $0.start, value: round(($0.getTotalTime(includeWarmUp, includeDropSet, includeCoolDown) / 60) * 100) / 100.0) }
//            .filter { $0.value > 0 }
//            .sorted { $0.date < $1.date }
    }
    
    private var showPrData: Bool { !prData.isEmpty }
    private var showOneRmData: Bool { !oneRmData.isEmpty }
    private var showWeightData: Bool { !weightData.isEmpty || !repsData.isEmpty }
    private var showDistanceData: Bool { !distanceData.isEmpty || !timeData.isEmpty }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            NavigationLink(destination: SelectExercise(selectedExercise: $exercise)) {
                HStack(alignment: .center) {
                    Text(exercise?.name ?? "Select Exercise")
                        .bodyText(size: 20, weight: .bold)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 14, weight: .bold))
                }
            }
            .textColor()
            
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
            
            if showPrData || showOneRmData || showWeightData || showDistanceData {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if showPrData {
                            // PR
                            Text("PR")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Current PR: \(prData.last?.value.formatted() ?? "0")\(UnitsManager.weight) (\(formatDate(prData.last?.date ?? Date()))")
                                    .bodyText(size: 16)
                                
                                Text("Keep going!")
                                    .bodyText(size: 14)
                            }
                            .textColor()
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: prData, units: UnitsManager.weight)
                        }
                        
                        if showOneRmData {
                            // 1RM
                            Text("ONE REP MAX (1RM)")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: oneRmData, units: UnitsManager.weight)
                        }
                        
                        if showWeightData {
                            // Weight
                            Text("TOTAL WEIGHT")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: weightData, units: UnitsManager.weight)
                            
                            // Reps
                            Text("TOTAL REPS")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: repsData, units: "reps")
                        }
                        
                        if showDistanceData {
                            // Distance
                            Text("TOTAL DISTANCE")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: distanceData, units: UnitsManager.longLength)
                            
                            // Time (Cardio)
                            Text("TOTAL CARDIO TIME")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            StatsLineChart(selectedRangeIndex: $selectedRangeIndex, data: timeData, units: "min")
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity)
            } else {
                Text("No Data")
                    .bodyText(size: 20)
                    .textColor()
            }
        }
    }
}
