//
//  WorkoutCalendar.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/19/25.
//

import SwiftUI

struct WorkoutCalendar: View {
    @State private var selectedDate = Date()
    
    let calendar = Calendar.current
    let workouts: [Date] // List of workout dates
    
    var body: some View {
        VStack {
            // Month Selector
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(monthYearString(for: selectedDate))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Days of the Week
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.bold)
                }
            }
            
            // Calendar Grid
            let days = generateMonthDays(for: selectedDate)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { day in
                    CalendarDay(date: day, hasWorkout: workouts.contains { isSameDay($0, day) })
                }
            }
        }
        .padding()
    }
    
    // Generate days for the selected month
    func generateMonthDays(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        var days: [Date] = []
        let startPadding = firstWeekday - calendar.firstWeekday
        let numDays = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        
        for dayOffset in (-startPadding)..<numDays {
            if let day = calendar.date(byAdding: .day, value: dayOffset, to: monthInterval.start) {
                days.append(day)
            }
        }
        
        return days
    }
    
    // Change month when arrows are clicked
    func changeMonth(by offset: Int) {
        if let newDate = calendar.date(byAdding: .month, value: offset, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    // Format month and year
    func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // Compare two dates
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
}

// MARK: - Calendar Day View
struct CalendarDay: View {
    let date: Date
    let hasWorkout: Bool
    
    let calendar = Calendar.current
    let today = Date()
    
    var body: some View {
        VStack {
            Text("\(calendar.component(.day, from: date))")
                .fontWeight(calendar.isDate(date, inSameDayAs: today) ? .bold : .regular)
                .foregroundColor(calendar.isDate(date, inSameDayAs: today) ? .blue : .primary)
                .frame(width: 30, height: 30)
            
            if hasWorkout {
                Circle()
                    .fill(Color.red)
                    .frame(width: 5, height: 5)
            }
        }
        .frame(width: 40, height: 40)
    }
}

// MARK: - Preview
struct WorkoutCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCalendar(workouts: [
            Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        ])
    }
}
