//
//  WorkoutSchedule.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/17/25.
//

import Foundation
import SwiftData

@Model
class WorkoutSchedule: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var days: [ScheduleDay]
    var startDate: Date
    
    init() {
        self.days = [ScheduleDay(index: 0, workouts: [])]
        self.startDate = Date()
    }
    
    func addDay() {
        days.append(ScheduleDay(index: (days.map { $0.index }.max() ?? -1) + 1, workouts: []))
    }
    
    func addDay(_ day: ScheduleDay) {
        for i in self.days.indices.filter({ $0 >= day.index }) {
            self.days[i].index += 1
        }
        
        days.insert(day, at: day.index)
    }
    
    func addDay(at index: Int) {
        for i in self.days.indices.filter({ $0 >= index }) {
            self.days[i].index += 1
        }
        
        days.insert(ScheduleDay(index: index, workouts: []), at: index)
    }
    
    func removeDay(_ day: ScheduleDay) {
        let index = day.index
        
        self.removeDay(at: index)
    }
    
    func removeDay(at index: Int) {
        guard index >= 0 && index < self.days.count else { return }
        
        DispatchQueue.main.async {
            self.days.remove(at: index)
            
            for i in self.days.indices.filter({ $0 > index }) {
                self.days[i].index -= 1
            }
        }
    }
    
    
    func changeStartDate(_ date: Date) {
        self.startDate = date
    }
}
