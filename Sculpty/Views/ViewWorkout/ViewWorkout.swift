//
//  ViewWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/16/25.
//

import SwiftUI
import SwiftData

struct ViewWorkout: View {
    @Environment(\.modelContext) private var context
    
    @StateObject private var viewModel: WorkoutViewModel
    @StateObject private var statsViewModel: StatsViewModel = StatsViewModel()
    
    @State private var exporting: Bool = false
    
    @State private var restTime: Double = 0
    
    @State private var showSummary: Bool = false
    private var summaryLog: WorkoutLog? {
        if log.completed { return log }
        
        do {
            return try context.fetch(FetchDescriptor<WorkoutLog>()).sorted(by: { $0.start > $1.start }).first(where: { $0.completed && $0.workout.id == viewModel.workout.id })
        } catch {
            return nil
        }
    }
    
    @State private var finishWorkout: Bool = false
    @State private var showFinishWorkoutAlert: Bool = false
    
    @AppStorage(UserKeys.disableAutoLock.rawValue) private var disableAutoLock: Bool = false
    
    var log: WorkoutLog
    
    init(workout: Workout, workoutLog: WorkoutLog) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(workout: workout))
        log = workoutLog
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    TabView {
                        ForEach(viewModel.exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
                            PerformExercise(workout: viewModel.workout, log: log, index: exercise.index, time: $restTime)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    Text("Rest Time: \(timeIntervalToString(time: getRemainingTime()))")
                }
                .onAppear() {
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        restTime = getRemainingTime()
                    }
                }
                .onChange(of: restTime) {
                    startRestTime(duration: restTime)
                }
                .onChange(of: log.allLogsDone) {
                    if !log.completed {
                        showFinishWorkoutAlert = true
                    }
                }
                .sheet(isPresented: $showSummary, onDismiss: { showSummary = false }) {
                    WorkoutSummary(workoutLog: summaryLog)
                }
                .alert(isPresented: $showFinishWorkoutAlert) {
                    Alert(
                        title: Text("Finish \(viewModel.workoutName)?"),
                        primaryButton: .destructive(Text("Finish")) {
                            log.finishWorkout()
                            
                            try? context.save()
                            
                            showFinishWorkoutAlert = false
                            finishWorkout = false
                            showSummary = true
                        },
                        secondaryButton: .cancel()
                    )
                }
                .confirmationDialog("Are you sure? This will skip all remaining sets", isPresented: $finishWorkout, titleVisibility: .visible) {
                    Button("Finish \(viewModel.workoutName)", role: .destructive) {
                        log.finishWorkout()
                        
                        try? context.save()
                        
                        finishWorkout = false
                        showFinishWorkoutAlert = false
                        showSummary = true
                    }
                }
                .fileExporter(
                    isPresented: $exporting,
                    document: viewModel.workout,
                    contentType: .json,
                    defaultFilename: "\(viewModel.workout.name).json"
                ) { result in
                    switch result {
                    case .success(_):
                        exporting = false
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .navigationTitle(viewModel.workoutName)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Button {
                                exporting = true
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    
                    if summaryLog != nil {
                        ToolbarItem(placement: .navigation) {
                            HStack {
                                Button {
                                    showSummary = true
                                } label: {
                                    Image(systemName: "info.circle")
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            NavigationLink(destination: EditWorkout(workout: viewModel.workout)) {
                                Image(systemName: "pencil")
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                finishWorkout = true
                            } label: {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
        }
        .onAppear() {
            if disableAutoLock {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
        .onDisappear() {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func startRestTime(duration: Double) {
        let endTime = Date().addingTimeInterval(duration)
        UserDefaults.standard.set(endTime, forKey: UserKeys.restEndTime.rawValue)
    }
    
    private func getRemainingTime() -> Double {
        guard let endTime = UserDefaults.standard.object(forKey: UserKeys.restEndTime.rawValue) as? Date else {
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
    
    ViewWorkout(workout: Workout(), workoutLog: WorkoutLog(workout: Workout()))
}
