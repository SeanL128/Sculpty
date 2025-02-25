//
//  WorkoutScheduler.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/17/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct WorkoutScheduler: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: WorkoutSchedulerViewModel
    
    @State var schedule: WorkoutSchedule
    @State var startDate: Date = Date()
    
    @AppStorage(UserKeys.scheduleDay.rawValue) private var dayData: Data = Data()
        
    init(schedule: WorkoutSchedule) {
        self.schedule = schedule
        _viewModel = StateObject(wrappedValue: WorkoutSchedulerViewModel(schedule: schedule))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Workout Schedule")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    .padding()
                    
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.days.sorted { $0.index < $1.index }, id: \.self) { day in
                                VStack {
                                    HStack(spacing: 20) {
                                        Text("Day \(day.index + 1)")
                                        
                                        Spacer()
                                        
                                        HStack {
                                            Text("Rest Day")

                                            Toggle("", isOn: Binding(
                                                get: { day.restDay },
                                                set: { newValue in
                                                    viewModel.toggleRestDay(for: day)
                                                }
                                            ))
                                            .labelsHidden()
                                        }
                                        .padding(.horizontal)
                                        
                                        Button {
                                            viewModel.removeDay(day)
                                        } label: {
                                            Image(systemName: "xmark.circle")
                                        }
                                        .disabled(viewModel.days.count <= 1)
                                    }
                                    
                                    if !day.restDay {
                                        VStack {
                                            ForEach(day.workouts, id: \.self) { workout in
                                                HStack {
                                                    Text(workout.name)
                                                        .font(.title3)
                                                    
                                                    Spacer()
                                                    
                                                    Button {
                                                        withAnimation {
                                                            day.removeWorkout(workout)
                                                        }
                                                    } label: {
                                                        Image(systemName: "xmark.circle")
                                                    }
                                                    .foregroundStyle(Color.accentColor)
                                                }
                                                
                                                if workout != day.workouts.last {
                                                    Divider()
                                                        .background(ColorManager.text)
                                                }
                                            }
                                            
                                            NavigationLink(destination: SelectWorkouts(day: day)) {
                                                HStack {
                                                    if day.workouts.isEmpty {
                                                        Image(systemName: "plus")
                                                        
                                                        Text("Add Workouts")
                                                    } else {
                                                        Image(systemName: "pencil")
                                                        
                                                        Text("Edit Workouts")
                                                    }
                                                }
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                                        )
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                                )
                            }
                            
                            Button {
                                viewModel.addDay()
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    
                                    Text("Add Day")
                                }
                            }
                            .softButtonStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                        }
                    }
                    .scrollClipDisabled()
                    
                    HStack {
                        DatePicker(
                            "Start Date",
                            selection: $viewModel.startDate,
                            displayedComponents: [.date]
                        )
                        .padding()
                        
                        Button {
                            save()
                        } label: {
                            Text("Save")
                        }
                        .softButtonStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
        }
    }
    
    private func save() {
        schedule.days = viewModel.days
        schedule.startDate = viewModel.startDate
        try? context.save()
        
        var day: ScheduleDay?
        
        if let daysPassed = Calendar.current.dateComponents([.day], from: schedule.startDate, to: Date()).day,
           !schedule.days.isEmpty {
            let index = daysPassed % schedule.days.count
            day = schedule.days[index].copy()
        } else {
            day = ScheduleDay(index: 0, workouts: [])
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(day!)
            dayData = data
        } catch {
            print(error.localizedDescription)
        }
        
        dismiss()
    }
}

#Preview {
    WorkoutScheduler(schedule: WorkoutSchedule())
}
