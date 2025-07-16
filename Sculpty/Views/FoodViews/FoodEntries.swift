//
//  FoodEntries.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/21/25.
//

import SwiftUI
import SwiftData

struct FoodEntries: View {
    @Environment(\.modelContext) private var context
    
    @State var log: CaloriesLog
    
    @State var caloriesBreakdown: (Double, Double, Double, Double)
    
    @State private var confirmDelete: Bool = false
    @State private var entryToDelete: FoodEntry?
    
    var body: some View {
        ContainerView(title: "Food Entries", spacing: 20, showScrollBar: true, lazy: true) {
            if !log.entries.isEmpty {
                ForEach(log.entries.sorted { $0.date < $1.date }, id: \.self) { entry in
                    FoodEntryRow(entry: entry, log: log)
                }
                
                Spacer()
                    .frame(height: 16)
                
                FatSecretLink()
            } else {
                EmptyState(
                    message: "No entries for \(formatDate(log.date))",
                    size: 18
                )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: log.entries.count)
    }
}
