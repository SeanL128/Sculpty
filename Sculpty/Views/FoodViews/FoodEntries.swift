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
    
    @State private var confirmDelete: Bool = false
    @State private var entryToDelete: FoodEntry?
    
    var body: some View {
        ContainerView(title: "Food Entries", spacing: .spacingL, lazy: true) {
            if !log.entries.isEmpty {
                ForEach(log.entries.sorted { $0.date < $1.date }, id: \.id) { entry in
                    FoodEntryRow(entry: entry, log: log)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: log.entries.count)
                
                Spacer()
                    .frame(height: 0)
                
                FatSecretLink()
            } else {
                EmptyState(
                    image: "fork.knife",
                    text: "No food entries logged for \(formatDate(log.date))",
                    subtext: "Log your first food"
                )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: log.entries.isEmpty)
    }
}
