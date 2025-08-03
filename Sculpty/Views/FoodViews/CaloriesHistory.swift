//
//  CaloriesHistory.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/7/25.
//

import SwiftUI
import SwiftData

struct CaloriesHistory: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \CaloriesLog.date, order: .reverse) private var logs: [CaloriesLog]
    
    private var caloriesLogs: [CaloriesLog] {
        logs.filter { !$0.entries.isEmpty }
    }
    
    var body: some View {
        ContainerView(title: "Calories History", spacing: .spacingL, lazy: true) {
            if !caloriesLogs.isEmpty {
                ForEach(caloriesLogs, id: \.id) { log in
                    CaloriesHistorySection(log: log)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                }
                .animation(.easeInOut(duration: 0.4), value: caloriesLogs.count)
                .animation(.easeInOut(duration: 0.3), value: caloriesLogs.map { $0.entries.count })
                
                Spacer()
                    .frame(height: 0)
                
                FatSecretLink()
            } else {
                EmptyState(
                    image: "fork.knife",
                    text: "No food entries logged",
                    subtext: "Log your first food"
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: caloriesLogs.isEmpty)
    }
}
