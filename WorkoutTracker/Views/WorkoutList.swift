//
//  WorkoutList.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/18/25.
//
import SwiftUI
import SwiftData

struct WorkoutList: View {
    @Environment(\.modelContext) var context
    
    @Query var workouts: [Workout]
    @Query var workoutLogs: [WorkoutLog]
    
    @State var delete: (Bool, Workout) = (false, Workout())
    
    var onWorkoutSelected: (Workout, WorkoutLog) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Workouts")
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    NavigationLink(destination: AddWorkout()) {
                        Image(systemName: "plus")
                    }
                }
                .padding()
                
                List {
                    ForEach(workouts) { workout in
                        HStack {
                            if let todayLog = workoutLogs.first(where: { log in
                                log.workout.id == workout.id &&
                                Calendar.current.isDate(Date(timeIntervalSince1970: log.start), inSameDayAs: Date())
                            }) {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        onWorkoutSelected(workout, todayLog)
                                    }
                                } label: {
                                    HStack {
                                        Text(workout.name)
                                        
                                        Spacer()
                                        
                                        if let previousLog = workoutLogs.sorted(by: { $0.start > $1.start }).first(where: { log in
                                            log.completed &&
                                            log.workout.id == workout.id &&
                                            !Calendar.current.isDate(Date(timeIntervalSince1970: log.start), inSameDayAs: Date())
                                        }) {
                                            Text(formatDate(Date(timeIntervalSince1970: previousLog.start)))
                                                .opacity(0.75)
                                        }
                                        
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundStyle(textColor)
                                }
                            } else {
                                HStack {
                                    Text(workout.name)
                                    Text("(Error - please restart app or alert developer)")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .swipeActions {
                            Button("Delete") {
                                delete.0 = true
                                delete.1 = workout
                            }
                            .tint(.red)
                        }
                    }
                }
                .backgroundStyle(.clear)
                .confirmationDialog("Are you sure?", isPresented: $delete.0) {
                    Button("Delete \(delete.1.name)?", role: .destructive) {
                        context.delete(delete.1)
                        try? context.save()
                        
                        delete.0 = false
                        delete.1 = Workout()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    @Previewable @State var showViewWorkout: Bool = false
    @Previewable @State var selectedWorkout: Workout?
    @Previewable @State var selectedLog: WorkoutLog?
    
    WorkoutList { workout, log in
        selectedWorkout = workout
        selectedLog = log
        showViewWorkout = true
    }
}
