//
//  HomeWorkoutSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI
import SwiftData

struct HomeWorkoutSection: View {
    @Environment(\.modelContext) private var context
    
    @State private var workoutToStart: WorkoutLog?
    
    private var startedWorkoutLogs: [WorkoutLog] {
        do {
            let now = Date()
            let oneHourAgo = now.addingTimeInterval(-3600)
            let twentyFourHoursAgo = now.addingTimeInterval(-86400)
            
            let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
                .filter {
                    ($0.started && $0.start >= twentyFourHoursAgo && !$0.completed) ||
                    ($0.completed && $0.end >= oneHourAgo) }
                .sorted { $0.start < $1.start }
            
            return logs
        } catch {
            debugLog("Error fetching logs: \(error.localizedDescription)")
        }
        
        return []
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HomeSectionHeader(icon: "dumbbell", title: "Workouts") {
                NavigationLink {
                    WorkoutStats()
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                        .headingImage()
                }
                .animatedButton()
                
                NavigationLink {
                    WorkoutList(workoutToStart: $workoutToStart)
                } label: {
                    Image(systemName: "plus")
                        .headingImage()
                }
                .animatedButton()
            }
            
            VStack(alignment: .center, spacing: .spacingM) {
                if !startedWorkoutLogs.isEmpty {
                    ForEach(Array(startedWorkoutLogs.enumerated()), id: \.element.id) { index, log in
                        if let workout = log.workout {
                            HomeWorkoutRow(log: log, workout: workout)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                            
                            if index < startedWorkoutLogs.count - 1 {
                                Divider()
                                    .background(ColorManager.border)
                                    .padding(.horizontal, -.spacingS)
                            }
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: startedWorkoutLogs.count)
                } else {
                    VStack(alignment: .center, spacing: .spacingXS) {
                        Text("No active workouts")
                            .bodyText(weight: .bold)
                        
                        Text("Click the + to get started")
                            .secondaryText()
                    }
                    .textColor()
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
                }
            }
            .card()
        }
        .onChange(of: workoutToStart) {
            if let log = workoutToStart {
                log.startWorkout()
                
                do {
                    try context.save()
                } catch {
                    debugLog("Error: \(error.localizedDescription)")
                }
                
                workoutToStart = nil
            }
        }
    }
}
