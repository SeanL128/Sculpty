//
//  Home.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/15/25.
//

import SwiftUI
import SwiftData
import Neumorphic
import SwiftUICharts
import Charts
import MijickPopups

struct Home: View {
    @Environment(\.modelContext) private var context
    
    @Query private var workouts: [Workout]
    @Query private var workoutLogs: [WorkoutLog]
    @Query(sort: \CaloriesLog.date) private var caloriesLogs: [CaloriesLog]
    @Query(sort: \Measurement.date) private var measurements: [Measurement]
    
    private var startedWorkoutLogs: [WorkoutLog] {
        do {
            let now = Date()
            let twentyFourHoursAgo = now.addingTimeInterval(-86400)
            let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
                .filter { $0.started && $0.start >= twentyFourHoursAgo && !$0.completed }
                .sorted { $0.start < $1.start }
            
            return logs
        } catch {
            print("Error fetching logs: \(error.localizedDescription)")
        }
        
        return []
    }
    
    @State private var log: CaloriesLog?
    @State private var fabOpen: Bool = false
    
    @State private var menuOpen: Bool = false
    
    @State private var workoutToStart: WorkoutLog? = nil
    @State private var measurementToAdd: Measurement? = nil
    
    private var eligibleMeasurementTypes: [MeasurementType] {
        var arr: [MeasurementType] = []
        
        for type in MeasurementType.displayOrder {
            let measurements = self.measurements.filter({ $0.type == type }).sorted(by: { $0.date < $1.date }).prefix(10)
            
            if measurements.count > 1 {
                arr.append(type)
            }
        }
        
        return arr
    }
    
    @AppStorage(UserKeys.onboarded.rawValue) private var onboarded = false
    @AppStorage(UserKeys.dailyCalories.rawValue) private var dailyCalories: String = "0"
    
    var caloriesBreakdown: (Double, Double, Double, Double) {
        guard let log = log else { return (0, 0, 0, 0) }
        
        var calories: Double { log.entries.reduce(0) { $0 + $1.calories } }
        var carbs: Double { log.entries.reduce(0) { $0 + $1.carbs } }
        var protein: Double { log.entries.reduce(0) { $0 + $1.protein } }
        var fat: Double { log.entries.reduce(0) { $0 + $1.fat } }
        
        return (calories, carbs, protein, fat)
    }
    
    var body: some View {
        if !onboarded {
            Onboarding()
                .transition(.opacity)
        } else {
            ContainerView(title: "Home", spacing: 24, showBackButton: false, trailingItems: {
                NavigationLink(destination: Options()) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .padding(.horizontal, 3)
                }
                .textColor()
            }) {
                //                    Circle()
                //                        .fill(LinearGradient(
                //                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                //                            startPoint: .topLeading,
                //                            endPoint: .bottomTrailing
                //                        ))
                //                        .frame(width: 350, height: 350)
                //                        .opacity(0.9)
                //                        .blur(radius: 400)
                
                // MARK: Workout Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(alignment: .center) {
                            Spacer()
                            
                            Image(systemName: "dumbbell")
                            
                            Spacer()
                        }
                        .frame(width: 25)
                        
                        Text("WORKOUTS")
                            .subheadingText()
                        
                        Spacer()
                        
                        NavigationLink(destination: ViewWorkoutLogs()) {
                            Image(systemName: "list.bullet.clipboard")
                                .padding(.horizontal, 3)
                        }
                        
                        NavigationLink(destination: WorkoutList(workoutToStart: $workoutToStart)) {
                            Image(systemName: "plus")
                                .padding(.trailing, 5)
                        }
                    }
                    .textColor()
                    
                    if !startedWorkoutLogs.isEmpty {
                        ForEach(startedWorkoutLogs, id: \.self) { log in
                            WorkoutDisplay(workout: log.workout, log: log)
                                .padding(.trailing, 6)
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text("Ready to track your workouts today")
                                .bodyText()
                            
                            Text("Click the + to get started")
                                .subbodyText()
                        }
                        .textColor()
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                    .frame(height: 5)
                
                // MARK: Calories Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(alignment: .center) {
                            Spacer()
                            
                            Image(systemName: "fork.knife")
                            
                            Spacer()
                        }
                        .frame(width: 25)
                        
                        Text("CALORIES")
                            .subheadingText()
                        
                        Spacer()
                        
                        NavigationLink(destination: CaloriesHistory()) {
                            Image(systemName: "list.bullet.clipboard")
                                .padding(.horizontal, 3)
                        }
                        
                        Button {
                            Task {
                                await AddFoodEntryPoup(log: log ?? CaloriesLog()).present()
                            }
                        } label: {
                            Image(systemName: "plus")
                                .padding(.trailing, 5)
                        }
                    }
                    .textColor()
                    
                    NavigationLink(destination: FoodEntries(log: log ?? CaloriesLog(), caloriesBreakdown: caloriesBreakdown)) {
                        HStack(alignment: .center) {
                            Text("\(caloriesBreakdown.0.formatted())cal")
                                .statsText()
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .padding(.leading, -2)
                        }
                        .textColor()
                        .padding(.bottom, -2)
                    }
                    
                    HStack(spacing: 4) {
                        Text("Remaining:")
                            .subbodyText()
                        
                        Text("\(((Double(dailyCalories) ?? 0) - caloriesBreakdown.0).formatted())cal")
                            .substatsText()
                    }
                    .secondaryColor()
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Text("\(caloriesBreakdown.1.formatted())g")
                                .substatsText()
                            
                            Text("Carbs")
                                .subbodyText()
                        }
                        .foregroundStyle(.blue)
                        
                        HStack(spacing: 4) {
                            Text("\(caloriesBreakdown.2.formatted())g")
                                .substatsText()
                            
                            Text("Protein")
                                .subbodyText()
                        }
                        .foregroundStyle(.red)
                        
                        HStack(spacing: 4) {
                            Text("\(caloriesBreakdown.3.formatted())g")
                                .substatsText()
                            
                            Text("Fat")
                                .subbodyText()
                        }
                        .foregroundStyle(.orange)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                    .frame(height: 5)
                
                // MARK: Measurement Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(alignment: .center) {
                            Spacer()
                            
                            Image(systemName: "ruler")
                            
                            Spacer()
                        }
                        .frame(width: 25)
                        
                        Text("MEASUREMENTS")
                            .subheadingText()
                        
                        Spacer()
                        
                        NavigationLink(destination: Measurements()) {
                            Image(systemName: "list.bullet.clipboard")
                                .padding(.trailing, 5)
                        }
                        
                        Button {
                            Task {
                                await AddMeasurementPopup(measurementToAdd: $measurementToAdd).present()
                            }
                        } label: {
                            Image(systemName: "plus")
                                .padding(.trailing, 5)
                        }
                    }
                    .textColor()
                    
                    if !eligibleMeasurementTypes.isEmpty {
                        TabView {
                            ForEach(eligibleMeasurementTypes, id: \.self) { type in
                                let measurements = self.measurements.filter({ $0.type == type }).sorted(by: { $0.date < $1.date }).prefix(10)
                                
                                
                                let latest = measurements.last!
                                
                                let rawData = measurements.map {
                                    if type == .bodyFat {
                                        return $0.measurement
                                    } else if type == .weight {
                                        return WeightUnit(rawValue: $0.unit)!.convert($0.measurement, to: WeightUnit(rawValue: "kg")!)
                                    } else {
                                        return ShortLengthUnit(rawValue: $0.unit)!.convert($0.measurement, to: ShortLengthUnit(rawValue: "cm")!)
                                    }
                                }
                                
                                let min = rawData.min() ?? 0
                                let max = rawData.max() ?? 0
                                
                                let data = rawData.map { ($0 - min) / (max - min) }
                                
                                VStack {
                                    HStack {
                                        Text(type.rawValue)
                                        
                                        Spacer()
                                        
                                        Text("\(latest.measurement.formatted())\(latest.unit)")
                                            .textCase(.uppercase)
                                    }
                                    .bodyText()
                                    .textColor()
                                    .frame(height: 45)
                                    
                                    Chart(data: data)
                                        .chartStyle(
                                            LineChartStyle(.quadCurve, lineColor: ColorManager.text, lineWidth: 3)
                                        )
                                        .frame(height: 75)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: 150)
                    } else {
                        VStack(alignment: .leading) {
                            Text("Ready to track your progress")
                                .bodyText()
                        }
                        .textColor()
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                    .frame(height: 5)
                
                // MARK: Stats Link
                NavigationLink(destination: Stats()) {
                    HStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Spacer()
                            
                            Image(systemName: "chart.xyaxis.line")
                            
                            Spacer()
                        }
                        .frame(width: 25)
                        
                        Text("STATS")
                            .subheadingText()
                        
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .padding(.leading, 4)
                            .padding(.trailing, 5)
                        
                        Spacer()
                    }
                }
                .textColor()
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .onAppear() {
                cleanupInvalidWorkouts()
                
                setCaloriesLog()
            }
            .onChange(of: log?.entries) {
                try? context.save()
            }
            .onChange(of: workoutToStart) {
                if let log = workoutToStart {
                    log.startWorkout()
                    
                    try? context.save()
                    
                    workoutToStart = nil
                }
            }
            .onChange(of: measurementToAdd) {
                if let measurement = measurementToAdd {
                    context.insert(measurement)
                    try? context.save()
                    
                    measurementToAdd = nil
                }
            }
        }
    }
    
    private func cleanupInvalidWorkouts() {
        let invalidWorkouts = workouts.filter { $0.index < 0 }
        
        if !invalidWorkouts.isEmpty {
            for workout in invalidWorkouts {
                workout.exercises.forEach { context.delete($0) }
                context.delete(workout)
            }
            
            try? context.save()
        }
    }
    
    private func setCaloriesLog() {
        var todaysLog = caloriesLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: Date())
        }
        
        if todaysLog == nil {
            todaysLog = CaloriesLog()
            context.insert(todaysLog!)
            try? context.save()
        }
        
        log = todaysLog!
    }
}

struct WorkoutDisplay: View {
    let workout: Workout
    let log: WorkoutLog
    
    var body: some View {
        NavigationLink(destination: ViewWorkout(log: log)) {
            HStack(alignment: .center) {
                Text(workout.name)
                    .boldLargeBodyText()
                    .textColor()
                    .truncationMode(.tail)
                
                Spacer()
                
                HStack {
                    ProgressView(value: log.getProgress())
                        .frame(height: 6)
                        .frame(width: 95)
                        .progressViewStyle(.linear)
                        .accentColor(ColorManager.text)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Text("\((log.getProgress() * 100).rounded().formatted())%")
                        .statsText()
                        .textColor()
                        .padding(.leading, 4)
                        .frame(width: 55)
                }
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .textColor()
            }
        }
    }
}

#Preview {
    Home()
}
