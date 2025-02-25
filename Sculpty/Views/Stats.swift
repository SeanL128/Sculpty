//
//  Stats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/19/25.
//

import SwiftUI
import SwiftData
import SwiftUICharts

struct Stats: View {
    @Query private var workouts: [Workout]
    @Query private var exercises: [Exercise]
    @Query(filter: #Predicate<WorkoutLog> { $0.started }, sort: \WorkoutLog.start) private var workoutLogs: [WorkoutLog]
    @Query private var measurements: [Measurement]
    
    @StateObject private var viewModel: StatsViewModel = StatsViewModel()
    
    @State private var selectedRange: TimeRange = .month
    @State private var rangeStart: Date?
    @State private var rangeEnd: Date?
    
    @State private var loaded: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack(alignment: .center) {
                        Text(viewModel.title)
                            .font(.title.bold())
                            .lineLimit(2)
                            .truncationMode(.tail)
                        
                        Spacer()
                        
//                        NavigationLink(destination: ViewLogs()) {
//                            Image(systemName: "list.bullet.clipboard")
//                        }
//                        .padding(.trailing, 10)
                        
                        Menu("View \(Image(systemName: "chevron.up.chevron.down"))") {
                            Menu("Workouts") {
                                Button {
                                    viewModel.selectOverall()
                                } label: {
                                    Text("Overall")
                                }
                                
                                Menu("By Workout") {
                                    ForEach(viewModel.data?.workouts ?? [], id: \.id) { workout in
                                        Button {
                                            viewModel.selectWorkout(workout: workout)
                                        } label: {
                                            Text(workout.name)
                                        }
                                    }
                                }
                                
                                Menu("By Exercise") {
                                    ForEach(viewModel.data?.exercises ?? [], id: \.self) { exercise in
                                        Button {
                                            viewModel.selectExercise(exercise: exercise)
                                        } label: {
                                            Text(exercise.name)
                                        }
                                    }
                                }
                            }
                            
                            Menu("Measurements") {
                                ForEach(viewModel.data?.measurementTypes ?? [], id: \.self) { measurementType in
                                    Button {
                                        viewModel.selectMeasurementType(measurementType: measurementType)
                                    } label: {
                                        Text(measurementType.rawValue)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        VStack {
                            if viewModel.showCharts {
                                if viewModel.workoutRelated {
                                    Text("Total Time: \(lengthToString(length: viewModel.selectedTotalTime))")
                                    
                                    VStack {
                                        PieChartView (
                                            data: viewModel.selectedMuscleGroupRepBreakdownChartData.map(\.0),
                                            title: "Muscle Group Reps Breakdown",
                                            form: ChartForm.large,
                                            dropShadow: false,
                                            segmentColors: viewModel.selectedMuscleGroupRepBreakdownChartData.map(\.2),
                                            unit: " reps"
                                        )
                                        
                                        MuscleGroupColorKey(muscleGroups: Array(viewModel.selectedMuscleGroupRepBreakdown.keys))
                                        
                                        VStack {
                                            ForEach(MuscleGroup.displayOrder, id: \.self) { key in
                                                if key != .overall && viewModel.selectedMuscleGroupRepBreakdown.keys.contains(key) {
                                                    Text("\(key.rawValue.capitalized): \(viewModel.selectedMuscleGroupRepBreakdown[key] ?? 0) reps")
                                                }
                                            }
                                        }
                                        .padding(.top)
                                        
                                        PieChartView (
                                            data: viewModel.selectedMuscleGroupWeightBreakdownChartData.map(\.0),
                                            title: "Muscle Group Weight Breakdown",
                                            form: ChartForm.large,
                                            dropShadow: false,
                                            segmentColors: viewModel.selectedMuscleGroupWeightBreakdownChartData.map(\.2),
                                            unit: UnitsManager.weight
                                        )
                                        
                                        MuscleGroupColorKey(muscleGroups: Array(viewModel.selectedMuscleGroupWeightBreakdown.keys))
                                        
                                        VStack {
                                            ForEach(MuscleGroup.displayOrder, id: \.self) { key in
                                                if key != .overall && viewModel.selectedMuscleGroupRepBreakdown.keys.contains(key) {
                                                    Text("\(key.rawValue.capitalized): \(viewModel.selectedMuscleGroupWeightBreakdown[key]?.formatted() ?? 0.formatted())\(UnitsManager.weight)")
                                                }
                                            }
                                        }
                                        .padding(.top)
                                    }
                                }
                            }
                            
                            if viewModel.showGraph {
                                if viewModel.showCharts {
                                    Divider()
                                        .padding()
                                }
                                
                                if viewModel.workoutRelated {
                                    VStack {
                                        Picker("Time Range", selection: $selectedRange) {
                                            ForEach(TimeRange.allCases, id: \.self) { range in
                                                Text(range.rawValue).tag(range)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                        .padding()
                                        .onChange(of: selectedRange) {
                                            viewModel.data?.filter(selectedRange: selectedRange, rangeStart: rangeStart, rangeEnd: rangeEnd)
                                        }
                                        
                                        if selectedRange == .custom {
                                            DatePicker(
                                                "Pick a start date",
                                                selection: Binding(
                                                    get: { rangeStart ?? Date() },
                                                    set: { rangeStart = $0 }
                                                ),
                                                in: workoutLogs.first!.start...Date(),
                                                displayedComponents: [.date]
                                            )
                                            .padding()

                                            if let start = rangeStart {
                                                DatePicker(
                                                    "Pick an end date",
                                                    selection: Binding(
                                                        get: { rangeEnd ?? start },
                                                        set: { rangeEnd = $0 }
                                                    ),
                                                    in: start...Date(),
                                                    displayedComponents: [.date]
                                                )
                                                .padding()
                                            }
                                        }
                                        
//                                        if viewModel.getWorkoutGraphInfo().map(\.0.count).max() ?? 0 > 1 {
                                            LineChartView(
                                                data: viewModel.getWorkoutGraphRepsInfo() ?? [],
                                                title: "Reps Trend",
                                                form: ChartForm.large
                                            )
                                            
                                            LineChartView(
                                                data: viewModel.getWorkoutGraphWeightInfo() ?? [],
                                                title: "Weight Trend",
                                                form: ChartForm.large
                                            )
//                                        } else {
//                                            Text("Not enough data in the selected date range.")
//                                        }
                                        
                                        Divider()
                                            .padding()
                                        
                                        VStack {
                                            let dateFormatter = DateFormatter()
                                            let _ = dateFormatter.dateFormat = "MM/dd/yyyy"
                                            
                                            HStack {
                                                Text("Date")
                                                    .frame(width: 100)
                                                
                                                Spacer()
                                                
                                                Text("Reps")
                                                    .frame(width: 100)
                                                
                                                Spacer()
                                                
                                                Text("Weight (\(UnitsManager.weight))")
                                                    .frame(width: 100)
                                            }
                                            
                                            ForEach(viewModel.getWorkoutRawGraphInfo(), id: \.0) { log in
                                                HStack {
                                                    Text(dateFormatter.string(from: log.2))
                                                        .frame(width: 100)
                                                    
                                                    Spacer()
                                                    
                                                    Text(log.0.formatted())
                                                        .frame(width: 100)
                                                    
                                                    Spacer()
                                                    
                                                    Text(log.1.formatted())
                                                        .frame(width: 100)
                                                }
                                            }
                                        }
                                        .textColor()
                                        .padding(.top)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear() {
            if !loaded {
                viewModel.update(workoutLogs: workoutLogs, measurements: measurements)
                viewModel.selectOverall()
                
                loaded = true
            }
        }
    }
}

#Preview {
    Stats()
}
