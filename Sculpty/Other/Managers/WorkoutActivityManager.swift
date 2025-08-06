//
//  WorkoutActivityManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/18/25.
//

import Foundation
import ActivityKit
import SwiftData
import UIKit

class WorkoutActivityManager: ObservableObject {
    static let shared = WorkoutActivityManager()
    
    private var currentActivity: Activity<WorkoutLiveActivityAttributes>?
    
    private static var activeWorkouts: [String: (log: WorkoutLog, lastUpdated: Date)] = [:]
    
    var hasActiveLiveActivity: Bool {
        return currentActivity != nil
    }
    
    private init() { }
    
    func startWorkoutActivity(for workoutLog: WorkoutLog) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        guard UIApplication.shared.applicationState == .active else { return }
        
        if let existingActivity = currentActivity,
           existingActivity.attributes.workoutId == workoutLog.id.uuidString { return }
        
        endCurrentActivity()
        
        let attributes = WorkoutLiveActivityAttributes(workoutId: workoutLog.id.uuidString)
        let contentState = createContentState(from: workoutLog)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: contentState, staleDate: nil),
                pushType: nil
            )
        } catch {
            debugLog("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateWorkoutActivity(for workoutLog: WorkoutLog) {
        guard let activity = currentActivity else {
            startWorkoutActivity(for: workoutLog)
            
            return
        }
        
        let contentState = createContentState(from: workoutLog)
        
        Task {
            await activity.update(
                ActivityContent(state: contentState, staleDate: nil)
            )
        }
    }
    
    func endCurrentActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(activity.content, dismissalPolicy: .immediate)
            
            currentActivity = nil
        }
    }
    
    func endWorkoutActivity(for workoutLog: WorkoutLog) {
        guard let activity = currentActivity else { return }
        
        let finalState = createContentState(from: workoutLog)
        
        Task {
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .after(.now + 5)
            )
            
            currentActivity = nil
        }
    }
    
    func registerActiveWorkout(_ workoutLog: WorkoutLog) {
        Self.activeWorkouts[workoutLog.id.uuidString] = (log: workoutLog, lastUpdated: Date())
        
        updateActiveWorkout()
    }
    
    func updateActiveWorkout(_ workoutLog: WorkoutLog? = nil) {
        if let workoutLog = workoutLog {
            Self.activeWorkouts[workoutLog.id.uuidString] = (log: workoutLog, lastUpdated: Date())
        }
        
        let workoutToShow = determineWorkoutToShow()
        
        if let workout = workoutToShow {
            updateWorkoutActivity(for: workout)
        }
    }
    
    func removeActiveWorkout(_ workoutId: String) {
        Self.activeWorkouts.removeValue(forKey: workoutId)
        
        if Self.activeWorkouts.isEmpty {
            endCurrentActivity()
        } else {
            if let newWorkout = determineWorkoutToShow() {
                updateWorkoutActivity(for: newWorkout)
            }
        }
    }
    
    private func determineWorkoutToShow() -> WorkoutLog? {
        guard !Self.activeWorkouts.isEmpty else { return nil }
        
        let recentlyUpdated = Self.activeWorkouts.values.filter {
            Date().timeIntervalSince($0.lastUpdated) < 30
        }
        
        if !recentlyUpdated.isEmpty {
            return recentlyUpdated.max { $0.lastUpdated < $1.lastUpdated }?.log
        } else {
            return Self.activeWorkouts.values.max {
                ($0.log.start) < ($1.log.start)
            }?.log
        }
    }
    
    private func createContentState(from workoutLog: WorkoutLog) -> WorkoutLiveActivityAttributes.ContentState {
        let currentExercise = getCurrentExercise(from: workoutLog)
        let currentSet = getCurrentSet(from: workoutLog)
        let nextSet = getNextSet(from: workoutLog)
        
        return WorkoutLiveActivityAttributes.ContentState(
            workoutName: workoutLog.workout?.name ?? "Workout",
            currentExerciseName: currentExercise?.exercise?.exercise?.name ?? "No Exercise",
            currentSetText: formatCurrentSet(currentSet),
            nextSetText: formatNextSet(nextSet),
            workoutProgress: workoutLog.getProgress()
        )
    }
    
    private func getCurrentExercise(from workoutLog: WorkoutLog) -> ExerciseLog? {
        return workoutLog.exerciseLogs
            .sorted { $0.index < $1.index }
            .first { !$0.completed }
    }
    
    private func getCurrentSet(from workoutLog: WorkoutLog) -> SetLog? {
        guard let currentExercise = getCurrentExercise(from: workoutLog) else { return nil }
        
        return currentExercise.setLogs
            .sorted { $0.index < $1.index }
            .first { !$0.completed && !$0.skipped }
    }
    
    private func getNextSet(from workoutLog: WorkoutLog) -> SetLog? {
        guard let currentExercise = getCurrentExercise(from: workoutLog),
              let currentSet = getCurrentSet(from: workoutLog) else { return nil }
        
        let remainingSets = currentExercise.setLogs
            .sorted { $0.index < $1.index }
            .filter { $0.index > currentSet.index }
        
        return remainingSets.first
    }
    
    private func formatCurrentSet(_ setLog: SetLog?) -> String {
        guard let setLog = setLog,
              let set = setLog.set else { return "" }
        
        if set.exerciseType == .weight,
           let reps = set.reps,
           let weight = set.weight {
            return "Current Set: \(reps)x\(String(format: "%.2f", weight))\(set.unit)"
        } else if set.exerciseType == .distance,
                  let distance = set.distance {
            return "Current Set: \(set.timeString) \(String(format: "%0.2f", distance))\(set.unit)"
        }
        
        return "Set \(set.index + 1)"
    }
    
    private func formatNextSet(_ setLog: SetLog?) -> String {
        guard let setLog = setLog,
              let set = setLog.set else { return "" }
        
        if set.exerciseType == .weight,
           let reps = set.reps,
           let weight = set.weight {
            return "Next Set: \(reps)x\(String(format: "%.2f", weight))\(set.unit)"
        } else if set.exerciseType == .distance,
                  let distance = set.distance {
            return "Next Set: \(set.timeString) \(String(format: "%0.2f", distance))\(set.unit)"
        }
        
        return "Set \(set.index + 1)"
    }
}
