//
//  ViewWorkout.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/16/25.
//

import SwiftUI
import Charts

struct ViewWorkout: View {
    @Environment(\.modelContext) private var context
    
    @StateObject private var viewModel: WorkoutViewModel
    @StateObject private var statsViewModel: StatsViewModel = StatsViewModel()
    
    @State private var restTime: Double = 0
    
    @State private var finishWorkout: Bool = false
    
    var log: WorkoutLog
    var onBack: () -> Void
    
    init(workout: Workout, workoutLog: WorkoutLog, onBack: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(workout: workout))
        log = workoutLog
        self.onBack = onBack
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onBack()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        
                        Spacer()
                    }
                    .frame(width: 55)
                    
                    Spacer()
                    
                    Text(viewModel.workoutName)
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    
                    HStack {
                        if !log.completed {
                            Spacer()
                        }
                        
//                        NavigationLink(destination: EditWorkout(workout: viewModel.workout)) {
//                            Image(systemName: "pencil")
//                        }
                        
                        if !log.completed {
                            Spacer()
                            
                            Button {
                                finishWorkout = true
                            } label: {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .frame(width: 55)
                    .confirmationDialog("Are you sure? This will skip all remaining sets", isPresented: $finishWorkout) {
                        Button("Finish \(viewModel.workoutName)?", role: .destructive) {
                            log.finishWorkout()
                            try? context.save()
                            
                            finishWorkout = false
                        }
                    }
                }
                .padding()
                
                if log.completed {
                    ScrollView {
                        VStack {
                            if statsViewModel.showCharts {
                                Text("Total Time: \(lengthToString(length: statsViewModel.selectedTotalTime))")
                                
                                VStack {
                                    let keys = Array(statsViewModel.selectedMuscleGroupRepBreakdown.keys)
                                    
                                    Chart {
                                        ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                                            if key != .overall && keys.contains(key) {
                                                SectorMark(
                                                    angle: .value(key.rawValue.capitalized, statsViewModel.selectedMuscleGroupRepBreakdown[key] ?? 0),
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
                                                Text("\(statsViewModel.selectedMuscleGroupRepBreakdown[.overall] ?? 0) reps")
                                                    .font(.title)
                                                    .position(x: frame.midX, y: frame.midY)
                                            }
                                        }
                                    }
                                    
                                    VStack {
                                        ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                                            if key != .overall && keys.contains(key) {
                                                Text("\(key.rawValue.capitalized): \(statsViewModel.selectedMuscleGroupRepBreakdown[key] ?? 0) reps")
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
                                                    angle: .value(key.rawValue.capitalized, statsViewModel.selectedMuscleGroupWeightBreakdown[key] ?? 0),
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
                                                Text("\(statsViewModel.selectedMuscleGroupWeightBreakdown[.overall]?.formatted() ?? 0.formatted())lbs")
                                                    .font(.title)
                                                    .position(x: frame.midX, y: frame.midY)
                                            }
                                        }
                                    }
                                    
                                    VStack {
                                        ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                                            if key != .overall && keys.contains(key) {
                                                Text("\(key.rawValue.capitalized): \(statsViewModel.selectedMuscleGroupWeightBreakdown[key]?.formatted() ?? 0.formatted())lbs")
                                            }
                                        }
                                    }
                                    .padding(.top)
                                }
                            }
                            
                            Spacer()
                        }
                        .navigationBarHidden(true)
                        .padding()
                    }
                } else {
                    TabView {
                        ForEach(viewModel.exercises.sorted { $0.index < $1.index }, id: \.self) { exercise in
                            PerformExercise(workout: viewModel.workout, log: log, index: exercise.index, time: $restTime)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    Text("Rest Time: \(timeIntervalToString(time: getRemainingTime()))")
                }
            }
            .navigationBarHidden(true)
            .onAppear() {
                statsViewModel.updateWorkoutLogs(workoutLogs: [log])
                statsViewModel.selectOverall()
                
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    restTime = getRemainingTime()
                }
            }
            .onChange(of: restTime) {
                startRestTime(duration: restTime)
            }
        }
    }
    
    private func startRestTime(duration: Double) {
        let endTime = Date().addingTimeInterval(duration)
        UserDefaults.standard.set(endTime, forKey: "restEndTime")
    }
    
    private func getRemainingTime() -> Double {
        guard let endTime = UserDefaults.standard.object(forKey: "restEndTime") as? Date else {
            return 0
        }
        
        return max(0, endTime.timeIntervalSinceNow)
    }
    
    private func timeIntervalToString(time: Double) -> String {
        let interval = Int(time)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    @Previewable @State var showViewWorkout: Bool = false
    
    ViewWorkout(workout: Workout(), workoutLog: WorkoutLog(workout: Workout()), onBack: {
        showViewWorkout = false;
    })
}
