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
            let logs = try context.fetch(FetchDescriptor<WorkoutLog>()).filter { $0.started && Calendar.current.isDate($0.start, inSameDayAs: Calendar.current.startOfDay(for: Date())) }.sorted { $0.start < $1.start }
            
             return logs
        } catch {
            print("Error fetching logs: \(error.localizedDescription)")
        }
        
        return []
    }
    
    @State private var log: CaloriesLog?
    @State private var fabOpen: Bool = false
    
    @State private var workoutToStart: WorkoutLog? = nil
    
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
            NavigationStack {
                ZStack {
                    ColorManager.background
                        .ignoresSafeArea(edges: .all)
                    
                    ScrollView {
                        // MARK: Header
                        HStack {
                            Text("HOME")
                                .font(.largeTitle)
                                .bold()
                            
                            Spacer()
                            
                            NavigationLink(destination: Options()) {
                                Image(systemName: "gear")
                                    .font(.title2)
                                    .padding(.horizontal, 3)
                            }
                            .foregroundStyle(ColorManager.text)
                            
                            Menu {
                                NavigationLink(destination: AddFoodEntry(log: log ?? CaloriesLog())) {
                                    HStack {
                                        Image(systemName: "fork.knife")
                                        
                                        Text("ADD FOOD")
                                    }
                                }
                                
                                NavigationLink(destination: AddMeasurement()) {
                                    HStack {
                                        Image(systemName: "ruler")
                                        
                                        Text("ADD MEASUREMENT")
                                    }
                                }
                                
                                NavigationLink(destination: AddWorkout()) {
                                    HStack {
                                        Image(systemName: "dumbbell")
                                        
                                        Text("ADD WORKOUT")
                                    }
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .padding(.horizontal, 3)
                            }
                            .foregroundStyle(ColorManager.text)
                        }
                        .padding(.bottom)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            // MARK: Workout Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "dumbbell")
                                    
                                    Text("WORKOUTS")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: ViewLogs()) {
                                        Image(systemName: "list.bullet.clipboard")
                                            .foregroundStyle(ColorManager.text)
                                            .padding(.trailing, 5)
                                    }
                                }
                                
                                ForEach(startedWorkoutLogs, id: \.self) { log in
                                    WorkoutDisplay(workout: log.workout, log: log)
                                    
                                    if log != startedWorkoutLogs.last {
                                        Spacer()
                                            .frame(height: 5)
                                    }
                                }
                                
                                HStack {
                                    NavigationLink(destination: WorkoutList(workoutToStart: $workoutToStart)) {
                                        Text("ALL WORKOUTS")
                                            .font(.footnote)
                                            .foregroundStyle(ColorManager.text)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Spacer()
                                .frame(height: 10)
                            
                            // MARK: Calories Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "fork.knife")
                                    
                                    Text("CALORIES")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: CaloriesHistory()) {
                                        Image(systemName: "list.bullet.clipboard")
                                            .foregroundStyle(ColorManager.text)
                                            .padding(.trailing, 5)
                                    }
                                }
                                
                                NavigationLink(destination: FoodEntries(log: log ?? CaloriesLog(), caloriesBreakdown: caloriesBreakdown)) {
                                    HStack {
                                        Text("\(caloriesBreakdown.0.formatted())CAL")
                                            .font(.headline)
                                            .fontWeight(.regular)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.footnote)
                                            .padding(.leading, 4)
                                    }
                                    .foregroundStyle(ColorManager.text)
                                    .padding(.bottom, -2)
                                }
                                
                                Text("REMAINING: \(((Double(dailyCalories) ?? 0) - caloriesBreakdown.0).formatted())CAL")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                HStack(spacing: 16) {
                                    Text("\(caloriesBreakdown.1.formatted())G CARBS")
                                        .foregroundStyle(.blue)
                                    Text("\(caloriesBreakdown.2.formatted())G PROTEIN")
                                        .foregroundStyle(.red)
                                    Text("\(caloriesBreakdown.3.formatted())G FAT")
                                        .foregroundStyle(.orange)
                                }
                                .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Spacer()
                                .frame(height: 10)
                            
                            // MARK: Measurement Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "ruler")
                                    
                                    Text("MEASUREMENTS")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: Measurements()) {
                                        Image(systemName: "list.bullet.clipboard")
                                            .foregroundStyle(ColorManager.text)
                                            .padding(.trailing, 5)
                                    }
                                }
                                
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
                                                .font(.title2)
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
                                        Text("NO DATA YET")
                                            .font(.headline)
                                            .fontWeight(.regular)
                                        
                                        Text("START TRACKING TO SEE YOUR PROGRESS")
                                            .font(.footnote)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Spacer()
                                .frame(height: 10)
                            
                            // MARK: Stats Link
                            NavigationLink(destination: Stats()) {
                                HStack {
                                    Image(systemName: "chart.xyaxis.line")
                                    
                                    Text("STATS")
                                        .bold()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline)
                                        .padding(.leading, 4)
                                        .padding(.trailing, 5)
                                    
                                    Spacer()
                                }
                            }
                            .foregroundStyle(ColorManager.text)
                            .frame(maxWidth: .infinity)
                            
                            Spacer()
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                    .scrollIndicators(.hidden)
                    .scrollClipDisabled()
                    .padding()
                }
                .toolbar(.hidden, for: .navigationBar)
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
                    .font(.headline)
                    .fontWeight(.semibold)
                    .truncationMode(.tail)
                
                Spacer()
                
                HStack {
                    ProgressView(value: log.getProgress())
                        .frame(height: 6)
                        .frame(minWidth: 75)
                        .frame(maxWidth: 115)
                        .progressViewStyle(.linear)
                        .accentColor(ColorManager.text)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Text("\((log.getProgress() * 100).rounded().formatted())%")
                        .padding(.leading, 4)
                }
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
            }
            .foregroundStyle(ColorManager.text)
        }
    }
}
