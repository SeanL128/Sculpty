//
//  Home.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/15/25.
//

import SwiftUI
import SwiftData
import Charts
import MijickPopups

struct Home: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @Query private var workouts: [Workout]
    @Query private var workoutLogs: [WorkoutLog]
    @Query(sort: \CaloriesLog.date) private var caloriesLogs: [CaloriesLog]
    @Query(sort: [SortDescriptor(\Measurement.date, order: .reverse)]) private var measurements: [Measurement]
    
    private var startedWorkoutLogs: [WorkoutLog] {
        do {
            let now = Date()
            let oneHourAgo = now.addingTimeInterval(-3600)
            let twentyFourHoursAgo = now.addingTimeInterval(-86400)
            let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
                .filter { ($0.started && $0.start >= twentyFourHoursAgo && !$0.completed) || ($0.completed && $0.end >= oneHourAgo) }
                .sorted { $0.start < $1.start }
            
            return logs
        } catch {
            debugLog("Error fetching logs: \(error.localizedDescription)")
        }
        
        return []
    }
    
    @State private var log: CaloriesLog?
    
    @State private var workoutToStart: WorkoutLog? = nil
    @State private var measurementToAdd: Measurement? = nil
    
    var caloriesBreakdown: (Double, Double, Double, Double) {
        guard let log = log else { return (0, 0, 0, 0) }
        
        var calories: Double { log.entries.reduce(0) { $0 + $1.calories } }
        var carbs: Double { log.entries.reduce(0) { $0 + $1.carbs } }
        var protein: Double { log.entries.reduce(0) { $0 + $1.protein } }
        var fat: Double { log.entries.reduce(0) { $0 + $1.fat } }
        
        return (calories, carbs, protein, fat)
    }
    
    var body: some View {
        ContainerView(title: "Home", spacing: 16, showBackButton: false, trailingItems: {
            NavigationLink(destination: Options()) {
                Image(systemName: "gear")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 20))
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
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("WORKOUTS")
                        .headingText(size: 24)
                    
                    Spacer()
                    
                    NavigationLink(destination: WorkoutStats()) {
                        Image(systemName: "chart.xyaxis.line")
                            .padding(.horizontal, 3)
                            .font(Font.system(size: 18))
                    }
                    
                    NavigationLink(destination: WorkoutList(workoutToStart: $workoutToStart)) {
                        Image(systemName: "plus")
                            .padding(.horizontal, 3)
                            .font(Font.system(size: 18))
                    }
                }
                .textColor()
                
                if !startedWorkoutLogs.isEmpty {
                    ForEach(startedWorkoutLogs, id: \.self) { log in
                        if let workout = log.workout {
                            NavigationLink(destination: ViewWorkout(log: log)) {
                                HStack(alignment: .center) {
                                    Text(workout.name)
                                        .bodyText(size: 18, weight: .bold)
                                        .truncationMode(.tail)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        ProgressView(value: log.getProgress())
                                            .frame(height: 6)
                                            .frame(width: 100)
                                            .progressViewStyle(.linear)
                                            .accentColor(ColorManager.text)
                                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                        
                                        Text("\((log.getProgress() * 100).rounded().formatted())%")
                                            .statsText(size: 16)
                                            .frame(width: 40)
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(.leading, -2)
                                        .font(Font.system(size: 12))
                                }
                            }
                            .textColor()
                            .padding(.trailing, 6)
                        }
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("Ready to track your workouts today")
                            .bodyText(size: 16)
                        
                        HStack(alignment: .center, spacing: 0) {
                            Text("Click the ")
                                .bodyText(size: 14)
                            
                            Image(systemName: "plus")
                                .font(Font.system(size: 8))
                            
                            Text(" to get started")
                                .bodyText(size: 14)
                        }
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
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("CALORIES")
                        .headingText(size: 24)
                    
                    Spacer()
                    
                    NavigationLink(destination: CaloriesStats()) {
                        Image(systemName: "chart.xyaxis.line")
                            .padding(.horizontal, 5)
                            .font(Font.system(size: 18))
                    }
                    
                    Button {
                        Task {
                            await AddFoodEntryPoup(log: log ?? CaloriesLog()).present()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .padding(.horizontal, 5)
                            .font(Font.system(size: 18))
                    }
                }
                .textColor()
                
                NavigationLink(destination: FoodEntries(log: log ?? CaloriesLog(), caloriesBreakdown: caloriesBreakdown)) {
                    HStack(alignment: .center) {
                        Text("\(caloriesBreakdown.0.formatted())cal")
                            .statsText(size: 16)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 10))
                    }
                    .textColor()
                    .padding(.bottom, -2)
                }
                
                HStack(spacing: 0) {
                    Text("Remaining: ")
                        .bodyText(size: 14)
                    
                    Text("\((Double(settings.dailyCalories) - caloriesBreakdown.0).formatted())cal")
                        .statsText(size: 14)
                }
                .secondaryColor()
                
                HStack(spacing: 16) {
                    HStack(spacing: 0) {
                        Text("\(caloriesBreakdown.1.formatted())g")
                            .statsText(size: 14)
                        
                        Text(" Carbs")
                            .bodyText(size: 14)
                    }
                    .foregroundStyle(.blue)
                    
                    HStack(spacing: 0) {
                        Text("\(caloriesBreakdown.2.formatted())g")
                            .statsText(size: 14)
                        
                        Text(" Protein")
                            .bodyText(size: 14)
                    }
                    .foregroundStyle(.red)
                    
                    HStack(spacing: 0) {
                        Text("\(caloriesBreakdown.3.formatted())g")
                            .statsText(size: 14)
                        
                        Text(" Fat")
                            .bodyText(size: 14)
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
                            .font(Font.system(size: 18))
                        
                        Spacer()
                    }
                    .frame(width: 25)
                    
                    Text("MEASUREMENTS")
                        .headingText(size: 24)
                    
                    Spacer()
                    
                    NavigationLink(destination: MeasurementStats()) {
                        Image(systemName: "chart.xyaxis.line")
                            .padding(.horizontal, 5)
                            .font(Font.system(size: 18))
                    }
                    
                    Button {
                        Task {
                            await AddMeasurementPopup(measurementToAdd: $measurementToAdd)
                                .setEnvironmentObject(settings)
                                .present()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .padding(.horizontal, 5)
                            .font(Font.system(size: 18))
                    }
                }
                .textColor()
                
                if !measurements.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        let latest = measurements.first!
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Text("\(latest.type.rawValue) (")
                                    .bodyText(size: 18)
                                    .textColor()
                                
                                Text("\(latest.measurement.formatted())\(latest.unit)")
                                    .statsText(size: 18)
                                    .textColor()
                                
                                Text(")")
                                    .bodyText(size: 18)
                                    .textColor()
                            }
                            
                            Text(formatDateWithTime(latest.date))
                                .bodyText(size: 12)
                                .secondaryColor()
                        }
                        
                        ForEach(1..<min(measurements.count, 3), id: \.self) { index in
                            let measurement = measurements[index]
                            
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("\(measurement.type.rawValue) (")
                                        .bodyText(size: 14)
                                        .textColor()
                                    
                                    Text("\(measurement.measurement.formatted())\(measurement.unit)")
                                        .statsText(size: 14)
                                        .textColor()
                                    
                                    Text(")")
                                        .bodyText(size: 14)
                                        .textColor()
                                }
                                
                                Text(formatDateWithTime(measurement.date))
                                    .bodyText(size: 10)
                                    .secondaryColor()
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("Ready to track your measurements")
                            .bodyText(size: 16)
                        
                        HStack(alignment: .center, spacing: 0) {
                            Text("Click the ")
                                .bodyText(size: 14)
                            
                            Image(systemName: "plus")
                                .font(Font.system(size: 8))
                            
                            Text("to get started ")
                                .bodyText(size: 14)
                        }
                    }
                    .textColor()
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Insights Link
//            NavigationLink(destination: Insights()) {
//                HStack(alignment: .center) {
//                    HStack(alignment: .center) {
//                        Spacer()
//                        
//                        Image(systemName: "chart.xyaxis.line")
//                            .font(Font.system(size: 18))
//                        
//                        Spacer()
//                    }
//                    .frame(width: 25)
//                    
//                    Text("INSIGHTS")
//                        .headingText(size: 24)
//                    
//                    Image(systemName: "chevron.right")
//                        .font(Font.system(size: 18))
//                        .padding(.leading, 4)
//                    
//                    Spacer()
//                }
//            }
//            .textColor()
//            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .onAppear() {
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
    
    private func setCaloriesLog() {
        let todaysLog = caloriesLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: Date())
        }
        
        if todaysLog == nil {
            let todaysLog = CaloriesLog()
            context.insert(todaysLog)
            try? context.save()
        }
        
        log = todaysLog
    }
}
