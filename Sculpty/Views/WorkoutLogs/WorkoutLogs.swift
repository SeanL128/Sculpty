//
//  WorkoutLogs.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI
import SwiftData
import MijickPopups

struct WorkoutLogs: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Workout.index) private var workouts: [Workout]
    @Query(filter: #Predicate<WorkoutLog> { $0.started }, sort: \WorkoutLog.start) private var workoutLogs: [WorkoutLog]

    private var validWorkouts: [Workout] {
        workouts.filter { workout in
            workoutLogs.contains { $0.workout?.id == workout.id }
        }
    }
    
    @State private var confirmDelete: Bool = false
    @State private var logToDelete: WorkoutLog? = nil
    
    var body: some View {
        ContainerView(title: "Workout Logs", spacing: 16, showScrollBar: true) {
            if !validWorkouts.isEmpty {
                ForEach(validWorkouts, id: \.id) { workout in
                    VStack(alignment: .leading, spacing: 16) {
                        Text(workout.name.uppercased())
                            .headingText(size: 14)
                            .textColor()
                            .padding(.bottom, -8)
                        
                        ForEach(workout.workoutLogs.sorted { $0.start > $1.start }, id: \.id) { log in
                            HStack(alignment: .center) {
                                NavigationLink(destination: ViewWorkoutLog(log: log)) {
                                    HStack(alignment: .center) {
                                        Text(formatDateWithTime(log.start))
                                            .bodyText(size: 16)
                                            .multilineTextAlignment(.leading)
                                        
                                        Image(systemName: "chevron.right")
                                            .padding(.leading, -2)
                                            .font(Font.system(size: 10))
                                    }
                                }
                                .textColor()
                                
                                Spacer()
                                
                                Button {
                                    logToDelete = log
                                    
                                    Task {
                                        await ConfirmationPopup(selection: $confirmDelete, promptText: "Delete log from \(formatDateWithTime(log.start)))?", resultText: "This cannot be undone.", cancelText: "Cancel", confirmText: "Delete").present()
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .padding(.horizontal, 8)
                                        .font(Font.system(size: 16))
                                }
                                .textColor()
                                .onChange(of: confirmDelete) {
                                    if confirmDelete,
                                       let log = logToDelete {
                                        context.delete(log)
                                        
                                        try? context.save()
                                        
                                        confirmDelete = false
                                        logToDelete = nil
                                    }
                                }
                            }
                            .padding(.trailing, 1)
                        }
                    }
                }
            } else {
                Text("No Data")
                    .bodyText(size: 18)
                    .textColor()
            }
        }
    }
}
