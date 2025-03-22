//
//  PerformWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/26/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct PerformWorkout: View {
    @Environment(\.modelContext) private var context
    
    @State private var log: WorkoutLog
    
    @State private var restTimer: Timer?
    @State private var restTime: Double = 0
    
    @AppStorage(UserKeys.disableAutoLock.rawValue) private var disableAutoLock: Bool = false
    
    init(log: WorkoutLog) {
        self.log = log
    }
    
    var body: some View {
        let _ = Self._printChanges()
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    TabView {
                        ForEach(log.exerciseLogs, id: \.id) { log in
                            PerformExercise(exerciseLog: log, time: $restTime)
                                .padding(.top)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    Text("Rest Time: \(timeIntervalToString(getRemainingTime()))")
                }
            }
            .onAppear() {
                restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    restTime = getRemainingTime()
                }
                
                if disableAutoLock {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
            }
            .onDisappear() {
                UIApplication.shared.isIdleTimerDisabled = false
                
                restTimer?.invalidate()
                restTimer = nil
            }
            .onChange(of: restTime) {
                startRestTime(duration: restTime)
            }
            .navigationTitle(log.workout.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink(destination: EditWorkout(workout: log.workout)) {
                            Image(systemName: "pencil")
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
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
    
    private func timeIntervalToString(_ time: Double) -> String {
        let interval = Int(time)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    PerformWorkout(log: WorkoutLog(workout: Workout()))
}
