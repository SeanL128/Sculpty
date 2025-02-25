//
//  WorkoutSchedulerViewModel.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/17/25.
//

import Foundation
import SwiftUI

class WorkoutSchedulerViewModel: ObservableObject {
    @Published var days: [ScheduleDay]
    @Published var startDate: Date
    
    private var schedule: WorkoutSchedule
    
    init(schedule: WorkoutSchedule) {
        self.schedule = schedule
        self.days = schedule.days
        self.startDate = schedule.startDate
    }
    
    func toggleRestDay(for day: ScheduleDay) {
        day.restDay.toggle()
        objectWillChange.send()
    }
    
    func addDay() {
        days.append(ScheduleDay(index: (days.map { $0.index }.max() ?? -1) + 1, workouts: []))
    }
    
    func removeDay(_ day: ScheduleDay) {
        let index = day.index
        
        self.removeDay(at: index)
    }
    
    func removeDay(at index: Int) {
        guard index >= 0 && index < days.count else { return }

        days.remove(at: index)
        renumberDays()
    }
    
    private func renumberDays() {
        for i in days.indices {
            days[i].index = i
        }
    }
}
