//
//  Stats.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/19/25.
//

import SwiftUI
import SwiftData
import Charts

struct Stats: View {
    @Query var workouts: [Workout]
    @Query var exercises: [Exercise]
    @Query var workoutLogs: [WorkoutLog]
    
    // View Model
    @StateObject private var viewModel: StatsViewModel = StatsViewModel()
    
    var body: some View {
        NavigationStack {
            HStack(alignment: .center) {
                Text(viewModel.title)
                    .font(.title.bold())
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                Spacer()
                
                Menu("View \(Image(systemName: "chevron.up.chevron.down"))") {
                    Button {
                        viewModel.selectOverall()
                    } label: {
                        Text("Overall")
                    }
                    
                    Menu("Workout") {
                        ForEach(viewModel.data?.workouts ?? [], id: \.self) { workout in
                            Button {
                                viewModel.selectWorkout(workout: workout)
                            } label: {
                                Text(workout.name)
                            }
                        }
                    }
                    
                    Menu("Exercise") {
                        ForEach(viewModel.data?.exercises ?? [], id: \.self) { exercise in
                            Button {
                                viewModel.selectExercise(exercise: exercise)
                            } label: {
                                Text(exercise.name)
                            }
                        }
                    }
                }
            }
            .padding()
            
            ScrollView {
                VStack {
                    if viewModel.showCharts {
                        Text("Total Time: \(lengthToString(length: viewModel.selectedTotalTime))")
                        
                        VStack {
                            let keys = Array(viewModel.selectedMuscleGroupRepBreakdown.keys)
                            
                            Chart {
                                ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                                    if key != .overall && keys.contains(key) {
                                        SectorMark(
                                            angle: .value(key.rawValue.capitalized, viewModel.selectedMuscleGroupRepBreakdown[key] ?? 0),
                                            innerRadius: .ratio(0.8),
                                            angularInset: 2
                                        )
                                        .cornerRadius(3)
                                        .foregroundStyle(MuscleGroup.colorMap[key]!)
                                    }
                                }
                            }
                            .scaledToFit()
                            .chartForegroundStyleScale(MuscleGroup.colorKeyValuePairs)
                            .chartLegend(.visible)
                            .chartLegend(alignment: .center, spacing: 8)
                            .chartBackground { chartProxy in
                                GeometryReader { geometry in
                                    if let anchor = chartProxy.plotFrame {
                                        let frame = geometry[anchor]
                                        Text("\(viewModel.selectedMuscleGroupRepBreakdown[.overall] ?? 0) reps")
                                            .font(.title)
                                            .position(x: frame.midX, y: frame.midY)
                                    }
                                }
                            }
                            
                            VStack {
                                ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                                    if key != .overall && keys.contains(key) {
                                        Text("\(key.rawValue.capitalized): \(viewModel.selectedMuscleGroupRepBreakdown[key] ?? 0) reps")
                                    }
                                }
                            }
                            .padding(.top)
                            
                            Divider()
                                .padding()
                            
                            Chart {
                                ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                                    if key != .overall && keys.contains(key) {
                                        SectorMark(
                                            angle: .value(key.rawValue.capitalized, viewModel.selectedMuscleGroupWeightBreakdown[key] ?? 0),
                                            innerRadius: .ratio(0.8),
                                            angularInset: 2
                                        )
                                        .cornerRadius(3)
                                        .foregroundStyle(MuscleGroup.colorMap[key]!)
                                    }
                                }
                            }
                            .scaledToFit()
                            .chartForegroundStyleScale(MuscleGroup.colorKeyValuePairs)
                            .chartLegend(.visible)
                            .chartLegend(alignment: .center, spacing: 8)
                            .chartBackground { chartProxy in
                                GeometryReader { geometry in
                                    if let anchor = chartProxy.plotFrame {
                                        let frame = geometry[anchor]
                                        Text("\(viewModel.selectedMuscleGroupWeightBreakdown[.overall]?.formatted() ?? 0.formatted())lbs")
                                            .font(.title)
                                            .position(x: frame.midX, y: frame.midY)
                                    }
                                }
                            }
                            
                            VStack {
                                ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                                    if key != .overall && keys.contains(key) {
                                        Text("\(key.rawValue.capitalized): \(viewModel.selectedMuscleGroupWeightBreakdown[key]?.formatted() ?? 0.formatted())lbs")
                                    }
                                }
                            }
                            .padding(.top)
                        }
                    }
                    
                    if viewModel.showGraph {
                        if viewModel.showCharts {
                            Divider()
                                .padding()
                        }
                        
                        VStack {
                            Picker("Graph View", selection: $viewModel.selectedGraphView) {
                                ForEach(["1W", "1M", "3M", "6M", "1Y", "2Y", "5Y"], id: \.self) { value in
                                    Text(value)
                                        .tag(value)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.bottom)
                            
                            let info = viewModel.getGraphInfo()
                            
                            Chart {
                                ForEach(info, id: \.0) { log in
                                    LineMark (
                                        x: .value("Date", Date(timeIntervalSince1970: log.2)),
                                        y: .value("Reps", log.0)
                                    )
                                    .foregroundStyle(by: .value("Value", "Reps"))
                                    
                                    PointMark (
                                        x: .value("Date", Date(timeIntervalSince1970: log.2)),
                                        y: .value("Reps", log.0)
                                    )
                                    .foregroundStyle(by: .value("Value", "Reps"))
                                    
                                    
                                    LineMark (
                                        x: .value("Date", Date(timeIntervalSince1970: log.2)),
                                        y: .value("Weight", log.1)
                                    )
                                    .foregroundStyle(by: .value("Value", "Weight"))
                                    
                                    PointMark (
                                        x: .value("Date", Date(timeIntervalSince1970: log.2)),
                                        y: .value("Weight", log.1)
                                    )
                                    .foregroundStyle(by: .value("Value", "Weight"))
                                }
                                .interpolationMethod(.catmullRom)
                            }
                            .chartForegroundStyleScale([
                                "Reps": textColor,
                                "Weight": .accentColor
                            ])
                            .chartXAxis {
                                AxisMarks(position: .bottom) {
                                    AxisValueLabel()
                                    AxisTick()
                                    AxisGridLine()
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { }
                            }
                            .chartXScale(domain: viewModel.getXScale())
                            .chartYScale(domain: -0.05...1.05)
                            .chartLegend(position: .bottom)
                            .chartPlotStyle { plotArea in
                                plotArea
                                    .background(Color.gray.opacity(0.1))
                                    .border(Color.gray, width: 1)
                            }
                            .clipped()
                            .frame(height: 400)
                            
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
                                    
                                    Text("Weight (lbs)")
                                        .frame(width: 100)
                                }
                                
                                ForEach(info, id: \.0) { log in
                                    HStack {
                                        Text(dateFormatter.string(from: Date(timeIntervalSince1970: log.2)))
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
                            .foregroundStyle(textColor)
                            .padding(.top)
                        }
                    }
                    
                    Spacer()
                }
                .navigationBarHidden(true)
                .padding()
            }
        }
        .onAppear() {
            viewModel.updateWorkoutLogs(workoutLogs: workoutLogs)
            viewModel.selectOverall()
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    Stats()
}
