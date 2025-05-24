//
//  WorkoutStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/23/25.
//

import SwiftUI
import SwiftData
import Charts

struct WorkoutStats: View {
    @Environment(\.modelContext) private var context
    
    @Query private var workoutLogs: [WorkoutLog]
    
    @State private var show: Bool = true
    
//    private var frequencyData: [(date: Date, value: Double)] {
//        let calendar = Calendar.current
//        
//        let dailyData = Dictionary(grouping: workoutLogs) { log in
//            calendar.startOfDay(for: log.start)
//        }.mapValues { logs in
//            Double(logs.count)
//        }
//        
//        guard let earliestDate = dailyData.keys.min(),
//              let latestDate = dailyData.keys.max() else {
//            return []
//        }
//        
//        let today = calendar.startOfDay(for: Date())
//        let endDate = latestDate > today ? latestDate : today
//        
//        var result: [(date: Date, value: Double)] = []
//        var currentDate = earliestDate
//        
//        while currentDate <= endDate {
//            let value = dailyData[currentDate] ?? 0.0
//            result.append((date: currentDate, value: value))
//            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
//        }
//        
//        return result
//    }
    
    var body: some View {
        ContainerView(title: "Workout Stats", spacing: 20, trailingItems: {
            NavigationLink(destination: WorkoutLogs()) {
                Image(systemName: "list.bullet.clipboard")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 24))
            }
        }) {
            if show {
                // Training Frequency
//                StatsLineChart(data: frequencyData, units: "x")
            } else {
                Text("No Data")
                    .bodyText(size: 20)
                    .textColor()
            }
        }
        .onAppear() {
//            dataValues = measurements.filter { $0.type == type }
//            
//            if typeOptions.isEmpty {
//                show = false
//            } else if !typeOptions.keys.contains(where: { $0 == type.rawValue }) {
//                type = MeasurementType(rawValue: typeOptions.keys.first!)!
//            }
        }
    }
}

#Preview {
    WorkoutStats()
}
