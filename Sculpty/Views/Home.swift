//
//  Home.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/15/25.
//

import SwiftUI
import SwiftData
import Neumorphic
import Charts
import MijickPopups

struct Home: View {
    @Environment(\.modelContext) var context
    
    @Query private var workouts: [Workout]
    @Query private var workoutLogs: [WorkoutLog]
    @Query(filter: #Predicate<WorkoutLog> { $0.started }, sort: \WorkoutLog.start) private var startedWorkoutLogs: [WorkoutLog]
    @Query(sort: \CaloriesLog.date) private var caloriesLogs: [CaloriesLog]
    @Query(sort: \Measurement.date) private var measurements: [Measurement]
    @Query private var schedules: [WorkoutSchedule]
    
    @State private var log: CaloriesLog?
    @State private var schedule: WorkoutSchedule?
    @State private var day: ScheduleDay?
    @State private var fabOpen: Bool = false
    
    @State private var workoutToStart: WorkoutLog? = nil
    
    @AppStorage(UserKeys.onboarded.rawValue) private var onboarded = false
    @AppStorage(UserKeys.dailyCalories.rawValue) private var dailyCalories: String = "0"
    @AppStorage(UserKeys.scheduleDay.rawValue) private var dayData: Data?
    
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
                    
                    ZStack (alignment: .bottomTrailing) {
                        ScrollView {
                            HStack {
                                Text("Home")
                                    .font(.largeTitle)
                                    .bold()
                                
                                Spacer()
                                
                                NavigationLink(destination: Options()) {
                                    Image(systemName: "gear")
                                        .font(.title2)
                                }
                                .foregroundStyle(ColorManager.text)
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            
                            VStack(spacing: 25) {
                                // MARK: Workout Section
                                VStack {
                                    HStack {
                                        Image(systemName: "dumbbell")
                                        
                                        Text("Today's Workout\(day?.workouts.count ?? 0 > 1 ? "s" : "")")
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        NavigationLink(destination: WorkoutScheduler(schedule: schedule ?? WorkoutSchedule())) {
                                            Image(systemName: "calendar")
                                                .foregroundStyle(ColorManager.text)
                                                .padding(.trailing, 5)
                                        }
                                    }
                                    
                                    Divider()
                                        .background(ColorManager.text)
                                    
                                    ForEach(startedWorkoutLogs, id: \.self) { log in
                                        WorkoutDisplay(workout: log.workout, log: log)
                                    }
                                    
                                    HStack {
                                        NavigationLink(destination: SelectWorkout(workoutToStart: $workoutToStart)) {
                                            Text("Start Workout")
                                                .font(.footnote)
                                                .foregroundStyle(ColorManager.text)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 7)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                                )
                                .onChange(of: workoutToStart) {
                                    if let log = workoutToStart {
                                        log.startWorkout()
                                        workoutToStart = nil
                                    }
                                }
                                
                                // MARK: Calories Section
                                VStack {
                                    HStack {
                                        Image(systemName: "fork.knife")
                                        
                                        Text("Today's Calories")
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        NavigationLink(destination: CaloriesHistory()) {
                                            Image(systemName: "list.bullet.clipboard")
                                                .foregroundStyle(ColorManager.text)
                                                .padding(.trailing, 5)
                                        }
                                    }
                                    
                                    Divider()
                                        .background(ColorManager.text)
                                    
                                    NavigationLink(destination: FoodEntries(log: log ?? CaloriesLog())) {
                                        HStack {
                                            VStack {
                                                HStack {
                                                    Text("\(caloriesBreakdown.0.formatted())cal (\(((Double(dailyCalories) ?? 0) - caloriesBreakdown.0).formatted())cal left)")
                                                        .fontWeight(.semibold)
                                                    
                                                    Spacer()
                                                }
                                                .font(.title2)
                                                .padding(.bottom, 5)
                                                
                                                HStack {
                                                    HStack {
                                                        Circle()
                                                            .fill(.blue)
                                                            .frame(width: 10, height: 10)
                                                        
                                                        Text("\(caloriesBreakdown.1.formatted())g Carbs")
                                                    }
                                                    
                                                    HStack {
                                                        Circle()
                                                            .fill(.red)
                                                            .frame(width: 10, height: 10)
                                                        
                                                        Text("\(caloriesBreakdown.2.formatted())g Protein")
                                                    }
                                                    
                                                    HStack {
                                                        Circle()
                                                            .fill(.orange)
                                                            .frame(width: 10, height: 10)
                                                        
                                                        Text("\(caloriesBreakdown.3.formatted())g Fat")
                                                    }
                                                    
                                                    Spacer()
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .padding(.trailing, 5)
                                        }
                                        .foregroundStyle(ColorManager.text)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                                )
                                
                                // MARK: Measurement Section
                                VStack {
                                    HStack {
                                        Image(systemName: "ruler")
                                        
                                        Text("Measurements")
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        NavigationLink(destination: Measurements()) {
                                            Image(systemName: "list.bullet.clipboard")
                                                .foregroundStyle(ColorManager.text)
                                                .padding(.trailing, 5)
                                        }
                                    }
                                    
                                    Divider()
                                        .background(ColorManager.text)
                                    
                                    TabView {
                                        ForEach(MeasurementType.displayOrder, id: \.self) { type in
                                            let measurements = self.measurements.filter({ $0.type == type })
                                            
                                            if !measurements.isEmpty {
                                                VStack {
                                                    HStack {
                                                        Text(type.rawValue)
                                                        
                                                        Spacer()
                                                        
                                                        Text("160lbs")
                                                    }
                                                    .font(.title2)
                                                    .frame(height: 45)
                                                    
                                                    Chart(data: [0.1, 0.3, 0.2, 0.5, 0.42, 0.9, 0.3])
                                                        .chartStyle(
                                                            LineChartStyle(.quadCurve, lineColor: .accentColor, lineWidth: 3)
                                                        )
                                                        .frame(height: 75)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    .tabViewStyle(.page)
                                    .frame(height: 150)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                                )
                                
                                // MARK: Stats Link
                                HStack {
                                    Image(systemName: "chart.xyaxis.line")
                                    
                                    NavigationLink(destination: Stats()) {
                                        HStack {
                                            Text("View Progress")
                                                .font(.title3)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .padding(.trailing, 5)
                                        }
                                        .foregroundStyle(ColorManager.text)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                                )
                                
                                Spacer()
                            }
                        }
                        .scrollClipDisabled()
                        
                        // MARK: Floating Buttons
                        HStack {
                            if fabOpen {
                                // Add Measurement
                                Button {
                                    Task {
                                        await AddMeasurementPopup().present()
                                    }
                                } label: {
                                    Image(systemName: "ruler")
                                }
                                .softButtonStyle(.circle, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                                
                                // Add Food
                                Button {
                                    Task {
                                        await AddFoodPopup(log: log ?? CaloriesLog()).present()
                                    }
                                } label: {
                                    Image(systemName: "fork.knife")
                                }
                                .softButtonStyle(.circle, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                                .padding(.horizontal)
                            }
                            
                            // Toggle
                            Toggle(isOn: $fabOpen) {
                                Image(systemName: fabOpen ? "xmark" : "plus")
                            }
                            .softToggleStyle(.circle, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding()
                }
                .toolbar(.hidden, for: .navigationBar)
            }
            .onAppear() {
                cleanupInvalidWorkouts()
                initLogs()
                
                setCaloriesLog()
                
                setSchedule()
            }
            .onChange(of: log?.entries) {
                try? context.save()
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

    private func initLogs() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastChecked = UserDefaults.standard.object(forKey: UserKeys.lastCheckedDate.rawValue) as? Date
        
        guard lastChecked == nil || !Calendar.current.isDate(lastChecked!, inSameDayAs: today) else {
            getScheduleDay()
            
            return
        }
        
        UserDefaults.standard.set(today, forKey: UserKeys.lastCheckedDate.rawValue)
        
        setScheduleDay()
        
        do {
            let workoutLogs: [WorkoutLog] = try context.fetch(FetchDescriptor<WorkoutLog>())
            let caloriesLogs: [CaloriesLog] = try context.fetch(FetchDescriptor<CaloriesLog>())
            
            workoutLogs
                .filter { !$0.started }
                .forEach { context.delete($0) }
            
            caloriesLogs
                .filter { $0.entries.isEmpty }
                .forEach { context.delete($0) }
            
            if workoutLogs.allSatisfy({ !Calendar.current.isDate($0.start, inSameDayAs: today) }) {
                workouts.forEach { context.insert(WorkoutLog(workout: $0)) }
            }
            
            if caloriesLogs.allSatisfy({ !Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                context.insert(CaloriesLog())
            }
            
            try context.save()
        } catch {
            print("Error fetching logs: \(error.localizedDescription)")
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
    
    private func setSchedule() {
        if schedules.isEmpty {
            schedule = WorkoutSchedule()
            context.insert(schedule!)
            
            try? context.save()
        } else {
            schedule = schedules[0]
        }
    }
    
    private func getScheduleDay() {
        if let data = dayData {
            do {
                let decoder = JSONDecoder()
                day = try decoder.decode(ScheduleDay.self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            setScheduleDay()
        }
    }
    
    private func setScheduleDay() {
        if let schedule = schedule,
           let daysPassed = Calendar.current.dateComponents([.day], from: schedule.startDate, to: Date()).day,
           !schedule.days.isEmpty {
            let index = daysPassed % schedule.days.count
            day = schedule.days[index].copy()
        } else {
            day = ScheduleDay(index: 0, workouts: [], restDay: true)
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(day!)
            dayData = data
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct WorkoutDisplay: View {
    let workout: Workout
    let log: WorkoutLog
    
    var body: some View {
        VStack {
            NavigationLink(destination: ViewWorkout(workout: workout, workoutLog: log)) {
                HStack {
                    Text(workout.name)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
                .foregroundStyle(ColorManager.text)
            }
            
            ProgressView(value: log.getProgress())
                .progressViewStyle(.linear)
                .accentColor(.green)
        }
    }
}
#Preview {
    Home()
}
