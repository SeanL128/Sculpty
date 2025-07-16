//
//  CaloriesHistory.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/7/25.
//

import SwiftUI
import SwiftData

struct CaloriesHistory: View {
    @Query(sort: \CaloriesLog.date, order: .reverse) private var logs: [CaloriesLog]
    private var caloriesLogs: [CaloriesLog] {
        logs.filter { !$0.entries.isEmpty }
    }
    
    var body: some View {
        ContainerView(title: "Calories History", spacing: 30, lazy: true) {
            if !caloriesLogs.isEmpty {
                ForEach(caloriesLogs, id: \.id) { log in
                    CaloriesHistorySection(log: log)
                }
                
                Spacer()
                    .frame(height: 16)
                
                FatSecretLink()
            } else {
                EmptyState(
                    message: "No Data",
                    size: 18
                )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: caloriesLogs.count)
    }
}
